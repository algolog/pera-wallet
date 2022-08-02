// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Router.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

class Router:
    AssetActionConfirmationViewControllerDelegate,
    NotificationObserver,
    SelectAccountViewControllerDelegate,
    TransactionControllerDelegate,
    WalletConnectorDelegate,
    WCConnectionApprovalViewControllerDelegate
    {
    var notificationObservations: [NSObjectProtocol] = []
    
    unowned let rootViewController: RootViewController
    
    /// <todo>
    /// How to dealloc finished transitions?
    private var ongoingTransitions: [BottomSheetTransition] = []

    private unowned let appConfiguration: AppConfiguration

    /// <todo>
    /// Change after refactoring routing
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    init(
        rootViewController: RootViewController,
        appConfiguration: AppConfiguration
    ) {
        self.rootViewController = rootViewController
        self.appConfiguration = appConfiguration
        
        startObservingNotifications()
    }
    
    deinit {
        stopObservingNotifications()
    }
    
    func launchAuthorization() {
        if findVisibleScreen(over: rootViewController) is ChoosePasswordViewController {
            return
        }
        
        route(
            to: .choosePassword(mode: .login, flow: nil),
            from: findVisibleScreen(over: rootViewController),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: true
        )
    }
    
    func launchOnboarding() {
        route(
            to: .welcome(flow: .initializeAccount(mode: .none)),
            from: findVisibleScreen(over: rootViewController),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: true
        ) { [weak self] in
            guard let self = self else { return }
            self.rootViewController.terminateTabs()
        }
    }
    
    func launchMain(completion: (() -> Void)? = nil) {
        rootViewController.launchTabsIfNeeded()
        rootViewController.dismissIfNeeded(animated: true, completion: completion)
    }
    
    func launcMainAfterAuthorization(
        presented viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        rootViewController.launchTabsIfNeeded()
        viewController.dismissScreen(completion: completion)
    }
    
    func launch(
        deeplink screen: DeepLinkParser.Screen
    ) {
        func launch(
            tab: TabBarItemID
        ) {
            if rootViewController.presentedViewController == nil {
                rootViewController.launch(tab: tab)
            }
        }
        
        switch screen {
        case .actionSelection(let address, let label):
            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            let eventHandler: QRScanOptionsViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .transaction:
                    launch(tab: .home)

                    var transactionDraft = SendTransactionDraft(
                        from: Account(),
                        transactionMode: .algo
                    )

                    let amount: UInt64 = 0
                    transactionDraft.amount = amount.toAlgos

                    let accountSelectDraft = SelectAccountDraft(
                        transactionAction: .send,
                        requiresAssetSelection: true,
                        transactionDraft: transactionDraft,
                        receiver: address
                    )

                    self.route(
                        to: .accountSelection(
                            draft: accountSelectDraft,
                            delegate: self
                        ),
                        from: self.findVisibleScreen(over: self.rootViewController),
                        by: .present
                    )

                case .watchAccount:
                    launch(tab: .home)

                    self.route(
                        to: .watchAccountAddition(
                            flow: .addNewAccount(
                                mode: .add(type: .watch)
                            ),
                            address: address
                        ),
                        from: self.findVisibleScreen(over: self.rootViewController),
                        by: .present
                    )
                case .contact:
                    launch(tab: .home)

                    self.route(
                        to: .addContact(address: address, name: label),
                        from: self.findVisibleScreen(over: self.rootViewController),
                        by: .present
                    )
                }
            }

            transition.perform(
                .qrScanOptions(
                    address: address,
                    eventHandler: eventHandler
                ),
                by: .present
            )

            ongoingTransitions.append(transition)
        case .algosDetail(let draft, let preferences):
            launch(tab: .home)

            route(
                to: .algosDetail(draft: draft, preferences: preferences),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )
        case .assetActionConfirmation(let draft, let theme):
            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            transition.perform(
                .assetActionConfirmation(
                    assetAlertDraft: draft,
                    delegate: self,
                    theme: theme
                ),
                by: .presentWithoutNavigationController
            )
            
            ongoingTransitions.append(transition)
        case .assetDetail(let draft, let preferences):
            launch(tab: .home)
            
            route(
                to: .assetDetail(draft: draft, preferences: preferences),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )

        case .sendTransaction(let draft, let shouldFilterAccount):
            launch(tab: .home)

            let transactionDraft = SendTransactionDraft(
                from: Account(),
                toAccount: Account(address: draft.toAccount, type: .standard),
                amount: draft.amount,
                transactionMode: draft.transactionMode,
                note: draft.note,
                lockedNote: draft.lockedNote
            )

            let accountSelectDraft = SelectAccountDraft(
                transactionAction: .send,
                requiresAssetSelection: false,
                transactionDraft: transactionDraft
            )

            route(
                to: .accountSelection(
                        draft: accountSelectDraft,
                        delegate: self,
                        shouldFilterAccount: shouldFilterAccount
                ),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )

        case .wcMainTransactionScreen(let draft):
            route(
                to: .wcMainTransactionScreen(draft: draft, delegate: rootViewController),
                from: findVisibleScreen(over: rootViewController),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                ),
                animated: true
            )
            
        case .buyAlgo(let draft):
            self.route(
                to: .buyAlgoHome(transactionDraft: draft, delegate: self),
                from: self.findVisibleScreen(over: self.rootViewController),
                by: .present
            )
        case .accountSelect(let asset):
            launch(tab: .home)

            let accountSelectDraft = SelectAccountDraft(
                transactionAction: .optIn(asset: asset),
                requiresAssetSelection: false
            )

            route(
                to: .accountSelection(draft: accountSelectDraft, delegate: self),
                from: findVisibleScreen(over: rootViewController),
                by: .present
            )
        }
    }
    
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from sourceViewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        guard let viewController = buildViewController(for: screen) else {
            return nil
        }
        
        switch style {
        case .root:
            if let currentViewController = self as? StatusBarConfigurable,
               let nextViewController = viewController as? StatusBarConfigurable {

                let isStatusBarHidden = currentViewController.isStatusBarHidden

                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }

            guard let navigationController = sourceViewController.navigationController else {
                return nil
            }

            navigationController.setViewControllers([viewController], animated: animated)
        case .push:
            if let currentViewController = self as? StatusBarConfigurable,
               let nextViewController = viewController as? StatusBarConfigurable {
                
                let isStatusBarHidden = currentViewController.isStatusBarHidden
                
                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }
            
            sourceViewController.navigationController?.pushViewController(viewController, animated: animated)
        case .launch:
            if !(sourceViewController is RootViewController) {
                sourceViewController.closeScreen(by: .dismiss, animated: false)
            }
            
            let navigationController: NavigationContainer
            
            if let navController = viewController as? NavigationContainer {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                   let presentedViewController = viewController as? StatusBarConfigurable,
                   presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationContainer(rootViewController: viewController)
            }
            
            navigationController.modalPresentationStyle = .fullScreen
            
            rootViewController.present(navigationController, animated: false, completion: completion)
        case .present,
                .customPresent:
            let navigationController: NavigationContainer
            
            if let navController = viewController as? NavigationContainer {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                   let presentedViewController = viewController as? StatusBarConfigurable,
                   presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationContainer(rootViewController: viewController)
            }
            
            if case .customPresent(
                let presentationStyle,
                let transitionStyle,
                let transitioningDelegate) = style {
                
                if let aPresentationStyle = presentationStyle {
                    navigationController.modalPresentationStyle = aPresentationStyle
                }
                if let aTransitionStyle = transitionStyle {
                    navigationController.modalTransitionStyle = aTransitionStyle
                }
                navigationController.transitioningDelegate = transitioningDelegate
            }
            
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            
            sourceViewController.present(navigationController, animated: animated, completion: completion)
        case .presentWithoutNavigationController:
            if let presentingViewController = self as? StatusBarConfigurable,
               let presentedViewController = viewController as? StatusBarConfigurable,
               presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
            viewController.modalPresentationCapturesStatusBarAppearance = true
            
            sourceViewController.present(viewController, animated: animated, completion: completion)
            
        case let .customPresentWithoutNavigationController(presentationStyle, transitionStyle, transitioningDelegate):
            if let presentingViewController = self as? StatusBarConfigurable,
               let presentedViewController = viewController as? StatusBarConfigurable,
               presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
            if let aPresentationStyle = presentationStyle {
                viewController.modalPresentationStyle = aPresentationStyle
            }
            if let aTransitionStyle = transitionStyle {
                viewController.modalTransitionStyle = aTransitionStyle
            }
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.transitioningDelegate = transitioningDelegate
            
            sourceViewController.present(viewController, animated: animated, completion: completion)
        case .set:
            if let currentViewController = self as? StatusBarConfigurable,
               let nextViewController = viewController as? StatusBarConfigurable {
                
                let isStatusBarHidden = currentViewController.isStatusBarHidden
                
                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }
            
            guard let navigationController = sourceViewController.navigationController else {
                return nil
            }
            
            var viewControllers = navigationController.viewControllers
            
            let firstViewController = viewControllers[0]
            
            viewControllers = [firstViewController, viewController]
            
            navigationController.setViewControllers(viewControllers, animated: animated)
        }
        
        guard let navigationController = viewController as? UINavigationController,
              let firstViewController = navigationController.viewControllers.first as? T else {
                  return viewController as? T
              }
        
        return firstViewController
    }
    
    // swiftlint:disable function_body_length
    private func buildViewController<T: UIViewController>(for screen: Screen) -> T? {
        let configuration = appConfiguration.all()

        let viewController: UIViewController
        
        switch screen {
        case let .welcome(flow):
            viewController = WelcomeViewController(flow: flow, configuration: configuration)
        case let .addAccount(flow):
            viewController = AddAccountViewController(flow: flow, configuration: configuration)
        case let .recoverAccount(flow):
            viewController = RecoverAccountViewController(flow: flow, configuration: configuration)
        case let .choosePassword(mode, flow):
            viewController = ChoosePasswordViewController(
                mode: mode,
                accountSetupFlow: flow,
                configuration: configuration
            )
        case let .passphraseView(flow, address):
            viewController = PassphraseBackUpViewController(flow: flow, address: address, configuration: configuration)
        case let .passphraseVerify(flow):
            viewController = PassphraseVerifyViewController(flow: flow, configuration: configuration)
        case let .accountNameSetup(flow, mode, accountAddress):
            viewController = AccountNameSetupViewController(flow: flow, mode: mode, accountAddress: accountAddress, configuration: configuration)
        case let .accountRecover(flow, initialMnemonic):
            viewController = AccountRecoverViewController(
                accountSetupFlow: flow,
                initialMnemonic: initialMnemonic,
                configuration: configuration
            )
        case let .qrScanner(canReadWCSession):
            viewController = QRScannerViewController(canReadWCSession: canReadWCSession, configuration: configuration)
        case let .qrGenerator(title, draft, isTrackable):
            let qrCreationController = QRCreationViewController(
                draft: draft,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration,
                isTrackable: isTrackable
            )
            qrCreationController.title = title
            viewController = qrCreationController
        case let .accountList(mode, delegate):
            let accountListViewController = AccountListViewController(mode: mode, configuration: configuration)
            accountListViewController.delegate = delegate
            viewController = accountListViewController
        case let .options(account, delegate):
            let optionsViewController = OptionsViewController(account: account, configuration: configuration)
            optionsViewController.delegate = delegate
            viewController = optionsViewController
        case .contacts:
            viewController = ContactsViewController(configuration: configuration)
        case let .editAccount(account, delegate):
            let aViewController = EditAccountViewController(account: account, configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case let .addContact(address, name):
            viewController = AddContactViewController(address: address, name: name, configuration: configuration)
        case let .editContact(contact):
            viewController = EditContactViewController(contact: contact, configuration: configuration)
        case let .contactDetail(contact):
            viewController = ContactDetailViewController(contact: contact, configuration: configuration)
        case .nodeSettings:
            viewController = NodeSettingsViewController(configuration: configuration)
        case let .transactionDetail(account, transaction, assetDetail):
            let transactionType =
            transaction.sender == account.address
            ? TransactionType.sent
            : .received

            viewController = TransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionType: transactionType,
                assetDetail: assetDetail,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case let .appCallTransactionDetail(
            account,
            transaction,
            transactionTypeFilter,
            assets,
            eventHandler
        ):
            let aViewController = AppCallTransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionTypeFilter: transactionTypeFilter,
                assets: assets,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case .appCallAssetList(let dataController, let eventHandler):
            let aViewController = AppCallAssetListViewController(
                dataController: dataController,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .assetDetail(draft, preferences):
            viewController = AssetDetailViewController(
                draft: draft,
                preferences: preferences,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case let .algosDetail(draft, preferences):
            viewController = AlgosDetailViewController(
                draft: draft,
                preferences: preferences,
                copyToClipboardController: nil,
                configuration: configuration
            )
        case let .accountDetail(accountHandle, eventHandler):
            let aViewController = AccountDetailViewController(
                accountHandle: accountHandle,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .assetSearch(accountHandle, dataController):
            viewController = AssetSearchViewController(
                accountHandle: accountHandle,
                dataController: dataController,
                configuration: configuration
            )
        case let .addAsset(account):
            viewController = AssetAdditionViewController(account: account, configuration: configuration)
        case .notifications:
            viewController = NotificationsViewController(configuration: configuration)
        case let .removeAsset(dataController):
            viewController = ManageAssetsViewController(
                dataController: dataController,
                configuration: configuration
            )
        case let .managementOptions(managementType, delegate):
            let managementOptionsViewController = ManagementOptionsViewController(managementType: managementType, configuration: configuration)
            managementOptionsViewController.delegate = delegate
            viewController = managementOptionsViewController
        case let .assetActionConfirmation(assetAlertDraft, delegate, theme):
            let aViewController = AssetActionConfirmationViewController(
                draft: assetAlertDraft,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration,
                theme: theme
            )
            aViewController.delegate = delegate
            viewController = aViewController
        case let .rewardDetail(account):
            viewController = RewardDetailViewController(
                account: account,
                configuration: configuration
            )
        case .verifiedAssetInformation:
            viewController = VerifiedAssetInformationViewController(configuration: configuration)
        case let .ledgerTutorial(flow):
            viewController = LedgerTutorialInstructionListViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerDeviceList(flow):
            viewController = LedgerDeviceListViewController(accountSetupFlow: flow, configuration: configuration)
        case let .ledgerApproval(mode, deviceName):
            viewController = LedgerApprovalViewController(mode: mode, deviceName: deviceName, configuration: configuration)
        case let .tutorialSteps(step):
            viewController = TutorialStepsViewController(
                step: step,
                configuration: configuration
            )
        case let .passphraseDisplay(address):
            viewController = PassphraseDisplayViewController(address: address, configuration: configuration)
        case .pinLimit:
            viewController = PinLimitViewController(configuration: configuration)
        case .assetActionConfirmationNotification,
                .assetDetailNotification:
            return nil
        case let .transactionFilter(filterOption, delegate):
            let transactionFilterViewController = TransactionFilterViewController(filterOption: filterOption, configuration: configuration)
            transactionFilterViewController.delegate = delegate
            viewController = transactionFilterViewController
        case let .transactionFilterCustomRange(fromDate, toDate):
            viewController = TransactionCustomRangeSelectionViewController(fromDate: fromDate, toDate: toDate, configuration: configuration)
        case let .rekeyInstruction(account):
            viewController = RekeyInstructionsViewController(account: account, configuration: configuration)
        case let .rekeyConfirmation(account, ledgerDetail, ledgerAddress):
            viewController = RekeyConfirmationViewController(
                account: account,
                ledger: ledgerDetail,
                ledgerAddress: ledgerAddress,
                configuration: configuration
            )
        case let .ledgerAccountSelection(flow, accounts):
            viewController = LedgerAccountSelectionViewController(
                accountSetupFlow: flow,
                accounts: accounts,
                configuration: configuration
            )
        case .walletRating:
            viewController = WalletRatingViewController(configuration: configuration)
        case .securitySettings:
            viewController = SecuritySettingsViewController(configuration: configuration)
        case .developerSettings:
            viewController = DeveloperSettingsViewController(configuration: configuration)
        case .currencySelection:
            viewController = CurrencySelectionViewController(
                dataController: CurrencySelectionListAPIDataController(
                    sharedDataController: appConfiguration.sharedDataController,
                    api: appConfiguration.api
                ),
                configuration: configuration
            )
        case .appearanceSelection:
            viewController = AppearanceSelectionViewController(configuration: configuration)
        case let .watchAccountAddition(flow, address):
            viewController = WatchAccountAdditionViewController(
                accountSetupFlow: flow,
                address: address,
                configuration: configuration
            )
        case let .ledgerAccountDetail(account, index, rekeyedAccounts):
            viewController = LedgerAccountDetailViewController(
                account: account,
                ledgerIndex: index,
                rekeyedAccounts: rekeyedAccounts,
                configuration: configuration
            )
        case let .notificationFilter(flow):
            viewController = NotificationFilterViewController(flow: flow, configuration: configuration)
        case let .bottomWarning(viewModel):
            viewController = BottomWarningViewController(viewModel, configuration: configuration)
        case let .tutorial(flow, tutorial):
            viewController = TutorialViewController(
                flow: flow,
                tutorial: tutorial,
                configuration: configuration
            )
        case let .transactionTutorial(isInitialDisplay):
            viewController = TransactionTutorialViewController(isInitialDisplay: isInitialDisplay, configuration: configuration)
        case let .recoverOptions(delegate):
            let accountRecoverOptionsViewController = AccountRecoverOptionsViewController(configuration: configuration)
            accountRecoverOptionsViewController.delegate = delegate
            viewController = accountRecoverOptionsViewController
        case let .ledgerAccountVerification(flow, selectedAccounts):
            viewController = LedgerAccountVerificationViewController(
                accountSetupFlow: flow,
                selectedAccounts: selectedAccounts,
                configuration: configuration
            )
        case let .wcConnectionApproval(walletConnectSession, delegate, completion):
            let wcConnectionApprovalViewController = WCConnectionApprovalViewController(
                walletConnectSession: walletConnectSession,
                walletConnectSessionConnectionCompletionHandler: completion,
                configuration: configuration
            )
            wcConnectionApprovalViewController.delegate = delegate
            viewController = wcConnectionApprovalViewController
        case .walletConnectSessionList:
            viewController = WCSessionListViewController(configuration: configuration)
        case .walletConnectSessionShortList:
            viewController = WCSessionShortListViewController(configuration: configuration)
        case let .wcTransactionFullDappDetail(viewModel):
            viewController = WCTransactionFullDappDetailViewController(
                viewModel,
                configuration: configuration
            )
        case let .wcAlgosTransaction(transaction, transactionRequest):
            viewController = WCAlgosTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetTransaction(transaction, transactionRequest):
            viewController = WCAssetTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetAdditionTransaction(transaction, transactionRequest):
            viewController = WCAssetAdditionTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcGroupTransaction(transactions, transactionRequest):
            viewController = WCGroupTransactionViewController(
                transactions: transactions,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAppCall(transaction, transactionRequest):
            viewController = WCAppCallTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetCreationTransaction(transaction, transactionRequest):
            viewController = WCAssetCreationTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetReconfigurationTransaction(transaction, transactionRequest):
            viewController = WCAssetReconfigurationTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .wcAssetDeletionTransaction(transaction, transactionRequest):
            viewController = WCAssetDeletionTransactionViewController(
                transaction: transaction,
                transactionRequest: transactionRequest,
                configuration: configuration
            )
        case let .jsonDisplay(jsonData, title):
            viewController = JSONDisplayViewController(jsonData: jsonData, title: title, configuration: configuration)
        case let .ledgerPairWarning(delegate):
            let ledgerPairWarningViewController = LedgerPairWarningViewController(configuration: configuration)
            ledgerPairWarningViewController.delegate = delegate
            viewController = ledgerPairWarningViewController
        case let .accountListOptions(accountType, eventHandler):
            let aViewController = AccountListOptionsViewController(accountType: accountType, configuration: configuration)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .sortAccountList(dataController, eventHandler):
            let aViewController  = SortAccountListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .accountSelection(draft, delegate, shouldFilterAccount):
            let dataController = SelectAccountAPIDataController(
                configuration.sharedDataController,
                transactionAction: draft.transactionAction
            )
            dataController.shouldFilterAccount = shouldFilterAccount
            let selectAccountViewController = SelectAccountViewController(
                dataController: dataController,
                draft: draft,
                configuration: configuration
            )
            selectAccountViewController.delegate = delegate
            viewController = selectAccountViewController
        case .assetSelection(let filter, let account, let receiver):
            viewController = SelectAssetViewController(
                filter: filter,
                account: account,
                receiver: receiver,
                configuration: configuration
            )
        case .sendTransaction(let draft):
            let sendScreen = SendTransactionScreen(draft: draft, configuration: configuration)
            sendScreen.isModalInPresentation = true
            viewController = sendScreen
        case .editNote(let note, let isLocked, let delegate):
            let editNoteScreen = EditNoteScreen(note: note, isLocked: isLocked, configuration: configuration)
            editNoteScreen.delegate = delegate
            viewController = editNoteScreen
        case .portfolioCalculationInfo(let result, let eventHandler):
            let aViewController = PortfolioCalculationInfoViewController(result: result, configuration: configuration)
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .invalidAccount(account, uiInteractions):
            let aViewController = InvalidAccountOptionsViewController(account: account, configuration: configuration)
            aViewController.uiInteractions = uiInteractions
            viewController = aViewController
        case .transactionResult:
            let resultScreen = TransactionResultScreen(configuration: configuration)
            resultScreen.isModalInPresentation = false
            viewController = resultScreen
        case .transactionAccountSelect(let draft):
            let dataController = AccountSelectScreenListAPIDataController(
                configuration.sharedDataController,
                api: configuration.api!
            )
            viewController = AccountSelectScreen(
                draft: draft,
                dataController: dataController,
                configuration: configuration
            )
        case .sendTransactionPreview(let draft, let transactionController):
            viewController = SendTransactionPreviewScreen(
                draft: draft,
                transactionController: transactionController,
                configuration: configuration
            )
        case let .wcMainTransactionScreen(draft, delegate):
            let aViewController = WCMainTransactionScreen(draft: draft, configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case .transactionFloatingActionButton:
            viewController = TransactionFloatingActionButtonViewController(configuration: configuration)
        case let .wcSingleTransactionScreen(transactions, transactionRequest, transactionOption):
            let currencyFormatter = CurrencyFormatter()
            let dataSource = WCMainTransactionDataSource(
                sharedDataController: configuration.sharedDataController,
                transactions: transactions,
                transactionRequest: transactionRequest,
                transactionOption: transactionOption,
                walletConnector: configuration.walletConnector,
                currencyFormatter: currencyFormatter
            )
            dataSource.load()
            viewController = WCSingleTransactionRequestScreen(
                dataSource: dataSource,
                configuration: configuration,
                currencyFormatter: currencyFormatter
            )
        case let .sortCollectibleList(dataController, eventHandler):
            let aViewController = SortCollectibleListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case let .collectiblesFilterSelection(filter):
            viewController = CollectiblesFilterSelectionViewController(
                filter: filter,
                configuration: configuration
            )
        case let .receiveCollectibleAccountList(dataController):
            viewController = ReceiveCollectibleAccountListViewController(
                dataController: dataController,
                configuration: configuration
            )
        case let .receiveCollectibleAssetList(account, dataController):
            viewController = ReceiveCollectibleAssetListViewController(
                account: account,
                dataController: dataController,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case let .collectibleDetail(asset, account, thumbnailImage):
            viewController = CollectibleDetailViewController(
                asset: asset,
                account: account,
                thumbnailImage: thumbnailImage,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
        case let .sendCollectible(draft):
            let aViewController = SendCollectibleViewController(
                draft: draft,
                configuration: configuration
            )
            viewController = aViewController
        case let .sendCollectibleAccountList(dataController):
            viewController = SendCollectibleAccountListViewController(
                dataController: dataController,
                configuration: configuration
            )
        case let .approveCollectibleTransaction(draft):
            viewController = ApproveCollectibleTransactionViewController(
                draft: draft,
                configuration: configuration
            )
        case let .shareActivity(items):
            let activityController = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )

            activityController.excludedActivityTypes = [
                UIActivity.ActivityType.addToReadingList
            ]

            viewController = activityController
        case .image3DCard(let image):
            viewController = Collectible3DImageViewController(
                image: image,
                configuration: configuration
            )
        case .video3DCard(let image, let url):
            viewController = Collectible3DVideoViewController(
                image: image,
                url: url,
                configuration: configuration
            )
        case .collectibleFullScreenImage(let draft):
            viewController = CollectibleFullScreenImageViewController(
                draft: draft,
                configuration: configuration
            )
        case .collectibleFullScreenVideo(let draft):
            viewController = CollectibleFullScreenVideoViewController(
                draft: draft,
                configuration: configuration
            )
        case .buyAlgoHome(let draft, let delegate):
            let buyAlgoHomeScreen = BuyAlgoHomeScreen(
                draft: draft,
                configuration: configuration
            )
            buyAlgoHomeScreen.delegate = delegate
            viewController = buyAlgoHomeScreen
        case let .buyAlgoTransaction(buyAlgoParams):
            viewController = BuyAlgoTransactionViewController(buyAlgoParams: buyAlgoParams, configuration: configuration)
        case .copyAddressStory(let eventHandler):
            let screen = CopyAddressStoryScreen(configuration: configuration)
            screen.eventHandler = eventHandler
            viewController = screen
        case .transactionOptions(let delegate):
            let aViewController = TransactionOptionsScreen(configuration: configuration)
            aViewController.delegate = delegate
            viewController = aViewController
        case .qrScanOptions(let address, let eventHandler):
            let screen = QRScanOptionsViewController(
                address: address,
                copyToClipboardController: ALGCopyToClipboardController(
                    toastPresentationController: appConfiguration.toastPresentationController
                ),
                configuration: configuration
            )
            screen.eventHandler = eventHandler
            viewController = screen
        case .sortAccountAsset(let dataController, let eventHandler):
            let aViewController = SortAccountAssetListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        case .innerTransactionList(let dataController, let eventHandler):
            let aViewController = InnerTransactionListViewController(
                dataController: dataController,
                configuration: configuration
            )
            aViewController.eventHandler = eventHandler
            viewController = aViewController
        }

        return viewController as? T
    }
    // swiftlint:enable function_body_length
}

extension Router {
    func findVisibleScreen(
        over screen: UIViewController? = nil
    ) -> UIViewController {
        let topmostPresentedScreen =
        findVisibleScreen(
            presentedBy: screen ?? rootViewController
        )

        return findVisibleScreen(
            in: topmostPresentedScreen
        )
    }

    func findVisibleScreen(
        presentedBy screen: UIViewController
    ) -> UIViewController {
        var topmostPresentedScreen = screen

        while let nextPresentedScreen = topmostPresentedScreen.presentedViewController {
            topmostPresentedScreen = nextPresentedScreen
        }
        return topmostPresentedScreen
    }

    func findVisibleScreen(
        in screen: UIViewController
    ) -> UIViewController {
        switch screen {
        case let navigationContainer as UINavigationController:
            return findVisibleScreen(
                in: navigationContainer
            )
        case let tabbedContainer as TabbedContainer:
            return findVisibleScreen(
                in: tabbedContainer
            )
        default:
            return screen
        }
    }

    func findVisibleScreen(
        in navigationContainer: UINavigationController
    ) -> UIViewController {
        return navigationContainer.viewControllers.last ?? navigationContainer
    }

    func findVisibleScreen(
        in tabbedContainer: TabbedContainer
    ) -> UIViewController {
        guard let selectedScreen = tabbedContainer.selectedScreen else {
            return tabbedContainer
        }

        switch selectedScreen {
        case let navigationContainer as UINavigationController:
            return findVisibleScreen(
                in: navigationContainer
            )
        default:
            return selectedScreen
        }
    }
}

extension Router {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        let draft = assetActionConfirmationViewController.draft
        
        guard let account = draft.account,
              !account.isWatchAccount() else {
            return
        }
        
        let assetTransactionDraft =
        AssetTransactionSendDraft(from: account, assetIndex: Int64(draft.assetId))
        let transactionController = TransactionController(
            api: appConfiguration.api,
            bannerController: appConfiguration.bannerController
        )

        transactionController.delegate = self
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
    }
}

extension Router {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        let sharedDataController = appConfiguration.sharedDataController
        let bannerController = appConfiguration.bannerController
        
        let hasNonWatchAccount = sharedDataController.accountCollection.contains {
            !$0.value.isWatchAccount()
        }
        
        if !hasNonWatchAccount {
            asyncMain { [weak bannerController] in
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )
            }
            return
        }

        asyncMain { [weak self] in
            guard let self = self else { return }
            
            let visibleScreen = self.findVisibleScreen(over: self.rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            transition.perform(
                .wcConnectionApproval(
                    walletConnectSession: session,
                    delegate: self,
                    completion: completion
                ),
                by: .present
            )
            
            self.ongoingTransitions.append(transition)
        }
    }

    func walletConnector(
        _ walletConnector: WalletConnector,
        didConnectTo session: WCSession
    ) {
        walletConnector.saveConnectedWCSession(session)
    }
}

extension Router {
    func wcConnectionApprovalViewControllerDidApproveConnection(
        _ wcConnectionApprovalViewController: WCConnectionApprovalViewController
    ) {
        let dAppName = wcConnectionApprovalViewController.walletConnectSession.dAppInfo.peerMeta.name
        
        wcConnectionApprovalViewController.dismissScreen {
            [weak self] in
            guard let self = self else { return }
            
            self.presentWCSessionsApprovedModal(dAppName: dAppName)
        }
    }

    func wcConnectionApprovalViewControllerDidRejectConnection(
        _ wcConnectionApprovalViewController: WCConnectionApprovalViewController
    ) {
        wcConnectionApprovalViewController.dismissScreen()
    }
    
    private func presentWCSessionsApprovedModal(
        dAppName: String
    ) {
        let visibleScreen = self.findVisibleScreen(over: self.rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        transition.perform(
            .bottomWarning(
                configurator:
                    BottomWarningViewConfigurator(
                        image: "icon-approval-check".uiImage,
                        title: "wallet-connect-session-connection-approved-title".localized(dAppName),
                        description: .plain(
                            "wallet-connect-session-connection-approved-description".localized(dAppName)
                        ),
                        secondaryActionButtonTitle: "title-close".localized
                    )
            ),
            by: .presentWithoutNavigationController
        )
        
        ongoingTransitions.append(transition)
    }
}

extension Router {
    private func startObservingNotifications() {
        observe(notification: WalletConnector.didReceiveSessionRequestNotification) {
            [weak self] notification in
            guard let self = self else { return }
            
            let userInfoKey = WalletConnector.sessionRequestUserInfoKey
            let maybeSessionKey = notification.userInfo?[userInfoKey] as? String

            guard let sessionKey = maybeSessionKey else {
                return
            }
            
            let walletConnector = self.appConfiguration.walletConnector
            
            walletConnector.delegate = self
            walletConnector.connect(to: sessionKey)
        }
    }
}

extension Router {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        switch draft.transactionAction {
        case .send:
            if draft.requiresAssetSelection {
                openAssetSelection(
                    with: account,
                    on: selectAccountViewController,
                    receiver: draft.receiver
                )
                return
            }
            
            sendTransction(
                from: selectAccountViewController,
                for: account,
                with: draft.transactionDraft
            )
        case .optIn(let asset):
            requestOptingInToAsset(
                asset,
                to: account
            )
        default:
            break
        }
    }

    private func sendTransction(
        from selectAccountViewController: SelectAccountViewController,
        for account: Account,
        with transactionDraft: TransactionSendDraft?
    ) {
        guard let transactionDraft = transactionDraft as? SendTransactionDraft else {
            return
        }

        let transactionMode = updateTransactionModeIfNeeded(
            transactionDraft,
            for: account
        )
        let draft = SendTransactionDraft(
            from: account,
            toAccount: transactionDraft.toAccount,
            amount: transactionDraft.amount,
            transactionMode: transactionMode,
            note: transactionDraft.note,
            lockedNote: transactionDraft.lockedNote
        )

        selectAccountViewController.open(
            .sendTransaction(
                draft: draft
            ),
            by: .push
        )
    }

    private func updateTransactionModeIfNeeded(
        _ draft: SendTransactionDraft,
        for account: Account
    ) -> TransactionMode {
        var transactionMode = draft.transactionMode

        if case let .asset(asset) = draft.transactionMode {
            let foundAsset = account[asset.id] ?? asset
            transactionMode = .asset(foundAsset)
        }

        return transactionMode
    }

    private func requestOptingInToAsset(
        _ asset: AssetID,
        to account: Account
    ) {
        if account.containsAsset(asset) {
            appConfiguration.bannerController.presentInfoBanner("asset-you-already-own-message".localized)
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetId: asset,
            asset: nil,
            transactionFee: Transaction.Constant.minimumFee,
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )

        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        ongoingTransitions.append(transition)

        transition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
            by: .presentWithoutNavigationController
        )
    }

    private func openAssetSelection(
        with account: Account,
        on screen: UIViewController,
        receiver: String?
    ) {
        let assetSelectionScreen: Screen = .assetSelection(
            filter: nil,
            account: account,
            receiver: receiver
        )

        screen.open(
            assetSelectionScreen,
            by: .push
        )
    }
}

extension Router: BuyAlgoHomeScreenDelegate {
    func buyAlgoHomeScreenDidFailedTransaction(_ screen: BuyAlgoHomeScreen) {
        screen.dismissScreen()
    }

    func buyAlgoHomeScreen(_ screen: BuyAlgoHomeScreen, didCompletedTransaction params: BuyAlgoParams) {
        screen.dismissScreen(animated: true) {
            self.displayAlgoTransactionScreen(for: params)
        }
    }
    
    private func displayAlgoTransactionScreen(for params: BuyAlgoParams) {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)
        
        ongoingTransitions.append(transition)
        
        transition.perform(
            .buyAlgoTransaction(buyAlgoParams: params),
            by: .presentWithoutNavigationController
        )
    }
}

/// <todo>
/// Should be handled for each specific transaction separately.
extension Router {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        switch error {
        case let .network(apiError):
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        visibleScreen.dismissScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            let currencyFormatter = CurrencyFormatter()
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            appConfiguration.bannerController.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            appConfiguration.bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            let visibleScreen = findVisibleScreen(over: rootViewController)
            let transition = BottomSheetTransition(presentingViewController: visibleScreen)

            ongoingTransitions.append(transition)

            transition.perform(
                .bottomWarning(
                    configurator: BottomWarningViewConfigurator(
                        image: "icon-info-green".uiImage,
                        title: "ledger-pairing-issue-error-title".localized,
                        description: .plain("ble-error-fail-ble-connection-repairing".localized),
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        let visibleScreen = findVisibleScreen(over: rootViewController)
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: visibleScreen)

        ongoingTransitions.append(ledgerApprovalTransition)

        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) { }

    func transactionControllerDidFailToSignWithLedger(
        _ transactionController: TransactionController
    ) { }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) { }
}
