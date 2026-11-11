import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/approve_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_all_requests_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_my_requests_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_pending_approvals_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_types_use_case.dart';
import 'package:flowboard/features/request/application/usecase/reject_request_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';
import 'package:flowboard/features/request/presentation/state/requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the requests screen: own requests, requests to approve, HR inbox and all requests.
class RequestsViewModel extends ViewModel<RequestsUiState> {
  /// Creates the view model; the first tab depends on the role of the viewer.
  RequestsViewModel({
    required CurrentEmployeeProvider currentEmployeeProvider,
    required this.getMyRequests,
    required this.getPendingApprovals,
    required this.getAllRequests,
    required this.getRequestTypes,
    required this.approveRequest,
    required this.rejectRequest,
  })  : _role = currentEmployeeProvider.currentRole(),
        super(RequestsUiState(
          role: currentEmployeeProvider.currentRole(),
          viewerId: currentEmployeeProvider.currentEmployeeId().value,
          selectedTab: RequestsTab.forRole(currentEmployeeProvider.currentRole()).first,
        ));

  final GetMyRequestsUseCase getMyRequests;
  final GetPendingApprovalsUseCase getPendingApprovals;
  final GetAllRequestsUseCase getAllRequests;
  final GetRequestTypesUseCase getRequestTypes;
  final ApproveRequestUseCase approveRequest;
  final RejectRequestUseCase rejectRequest;

  final UserRole _role;

  /// Loads the lists of the role and the request types of the filter.
  void load() {
    if (_role == UserRole.employee) _loadMine();
    _loadPending();
    _loadTypes();
    if (state.selectedTab == RequestsTab.all) _loadAll();
  }

  /// Shows [tab]; the list of all requests is loaded the first time it is shown.
  void onTabSelected(RequestsTab tab) {
    update((RequestsUiState s) => s.copyWith(selectedTab: tab));
    if (tab == RequestsTab.all && state.allRequests.isEmpty) _loadAll();
  }

  /// Shows the message left by another screen and reloads the lists.
  void onResult(String message) {
    update((RequestsUiState s) => s.copyWith(snackbarMessage: message));
    load();
  }

  /// Clears the message once it was shown.
  void consumeMessage() => update((RequestsUiState s) => s.copyWith(snackbarMessage: null));

  Future<void> _loadMine() async {
    final MyRequestsFilter filter = state.myFilter;
    update((RequestsUiState s) => s.copyWith(isLoadingMine: s.myRequests.isEmpty, mineError: null));
    try {
      final RequestPage result = await getMyRequests.execute(status: filter.status);
      if (state.myFilter != filter) return;
      update((RequestsUiState s) => s.copyWith(
            isLoadingMine: false,
            myRequests: result.items,
            minePaging: PagingState.after(result),
          ));
    } catch (error) {
      update((RequestsUiState s) => s.copyWith(
            isLoadingMine: false,
            mineError: requestErrorMessage(error, RequestAction.load, 'No se pudieron cargar tus solicitudes.'),
          ));
    }
  }

  /// Filters the viewer's own requests.
  void onMyFilterSelected(MyRequestsFilter filter) {
    if (filter == state.myFilter) return;
    update((RequestsUiState s) =>
        s.copyWith(myFilter: filter, myRequests: const <Request>[], minePaging: const PagingState()));
    _loadMine();
  }

  /// Loads the next page of the viewer's requests and adds it at the end of the list.
  Future<void> loadMoreMine() async {
    final RequestsUiState current = state;
    if (!current.minePaging.canLoadMore) return;
    final MyRequestsFilter filter = current.myFilter;
    update((RequestsUiState s) =>
        s.copyWith(minePaging: s.minePaging.copyWith(isLoadingMore: true, loadMoreFailed: false)));
    try {
      final RequestPage result = await getMyRequests.execute(
        status: filter.status,
        page: PagingState.nextPage(current.myRequests.length),
      );
      if (state.myFilter != filter) return;
      update((RequestsUiState s) => s.copyWith(
            myRequests: PagingState.merge(s.myRequests, result),
            minePaging: PagingState.after(result),
          ));
    } catch (_) {
      if (state.myFilter != filter) return;
      update((RequestsUiState s) =>
          s.copyWith(minePaging: s.minePaging.copyWith(isLoadingMore: false, loadMoreFailed: true)));
    }
  }

  Future<void> _loadPending() async {
    final int? typeId = state.typeFilter?.id;
    final ApprovalSort sort = state.sort;
    update((RequestsUiState s) => s.copyWith(isLoadingPending: s.pending.isEmpty, pendingError: null));
    try {
      final RequestPage result = await getPendingApprovals.execute(requestTypeId: typeId, sort: sort.order);
      if (state.typeFilter?.id != typeId || state.sort != sort) return;
      update((RequestsUiState s) => s.copyWith(
            isLoadingPending: false,
            pending: result.items,
            pendingTotal: result.totalItems,
            pendingPaging: PagingState.after(result),
          ));
    } catch (error) {
      update((RequestsUiState s) => s.copyWith(
            isLoadingPending: false,
            pendingError: requestErrorMessage(error, RequestAction.load, 'No se pudo cargar la bandeja.'),
          ));
    }
  }

  Future<void> _loadTypes() async {
    final List<RequestType>? types = await attemptOrNull(() => getRequestTypes.execute());
    if (types != null) update((RequestsUiState s) => s.copyWith(requestTypes: types));
  }

  /// Filters the requests to approve by [type]; null shows every type.
  void onTypeFilterSelected(RequestType? type) {
    if (type?.id == state.typeFilter?.id) return;
    update((RequestsUiState s) =>
        s.copyWith(typeFilter: type, pending: const <Request>[], pendingPaging: const PagingState()));
    _loadPending();
  }

  /// Orders the requests to approve.
  void onSortSelected(ApprovalSort sort) {
    if (sort == state.sort) return;
    update((RequestsUiState s) => s.copyWith(sort: sort, pending: const <Request>[], pendingPaging: const PagingState()));
    _loadPending();
  }

  /// Loads the next page of the pending requests and adds it at the end of the list.
  Future<void> loadMorePending() async {
    final RequestsUiState current = state;
    if (!current.pendingPaging.canLoadMore) return;
    final int? typeId = current.typeFilter?.id;
    final ApprovalSort sort = current.sort;
    update((RequestsUiState s) =>
        s.copyWith(pendingPaging: s.pendingPaging.copyWith(isLoadingMore: true, loadMoreFailed: false)));
    try {
      final RequestPage result = await getPendingApprovals.execute(
        requestTypeId: typeId,
        sort: sort.order,
        page: PagingState.nextPage(current.pending.length),
      );
      if (state.typeFilter?.id != typeId || state.sort != sort) return;
      update((RequestsUiState s) => s.copyWith(
            pending: PagingState.merge(s.pending, result),
            pendingTotal: result.totalItems,
            pendingPaging: PagingState.after(result),
          ));
    } catch (_) {
      if (state.typeFilter?.id != typeId || state.sort != sort) return;
      update((RequestsUiState s) =>
          s.copyWith(pendingPaging: s.pendingPaging.copyWith(isLoadingMore: false, loadMoreFailed: true)));
    }
  }

  /// Approves [request] from the list.
  Future<void> approve(Request request) async {
    if (state.processingRequestId != null || !state.canResolve(request)) return;
    update((RequestsUiState s) => s.copyWith(processingRequestId: request.id));
    try {
      final Request approved = await approveRequest.execute(request);
      update((RequestsUiState s) => s.copyWith(
            processingRequestId: null,
            pending: s.pending.where((Request item) => item.id != approved.id).toList(),
            pendingTotal: s.pendingTotal > 0 ? s.pendingTotal - 1 : 0,
            snackbarMessage: 'Solicitud de ${RequestFormatters.shortName(request.requesterName)} aprobada.',
          ));
    } catch (error) {
      update((RequestsUiState s) => s.copyWith(
            processingRequestId: null,
            snackbarMessage: requestErrorMessage(error, RequestAction.resolve, 'No se pudo aprobar la solicitud.'),
          ));
    }
  }

  /// Opens the dialog to reject [request].
  void showRejectDialog(Request request) {
    if (!state.canResolve(request)) return;
    update((RequestsUiState s) => s.copyWith(rejectForm: RejectForm(request: request)));
  }

  /// Closes the reject dialog.
  void dismissRejectDialog() => update((RequestsUiState s) => s.copyWith(rejectForm: null));

  /// Changes the reason of the rejection.
  void onRejectReasonChange(String value) {
    update((RequestsUiState s) => s.copyWith(rejectForm: s.rejectForm?.copyWith(reason: value, error: null)));
  }

  /// Rejects the request of the dialog with its reason.
  Future<void> confirmReject() async {
    final RejectForm? form = state.rejectForm;
    if (form == null || form.isSaving) return;
    if (form.reason.trim().isEmpty) {
      update((RequestsUiState s) =>
          s.copyWith(rejectForm: form.copyWith(error: 'Ingresa el motivo para rechazar la solicitud.')));
      return;
    }
    update((RequestsUiState s) => s.copyWith(rejectForm: form.copyWith(isSaving: true)));
    try {
      final Request rejected = await rejectRequest.execute(form.request, form.reason);
      update((RequestsUiState s) => s.copyWith(
            rejectForm: null,
            pending: s.pending.where((Request item) => item.id != rejected.id).toList(),
            pendingTotal: s.pendingTotal > 0 ? s.pendingTotal - 1 : 0,
            snackbarMessage: 'Solicitud de ${RequestFormatters.shortName(form.request.requesterName)} rechazada.',
          ));
    } catch (error) {
      update((RequestsUiState s) => s.copyWith(
            rejectForm: s.rejectForm?.copyWith(
              isSaving: false,
              error: requestErrorMessage(error, RequestAction.resolve, 'No se pudo rechazar la solicitud.'),
            ),
          ));
    }
  }

  Future<void> _loadAll() async {
    final AllRequestsFilter filter = state.allFilter;
    update((RequestsUiState s) => s.copyWith(isLoadingAll: s.allRequests.isEmpty, allError: null));
    try {
      final RequestPage result = await getAllRequests.execute(status: filter.status);
      if (state.allFilter != filter) return;
      update((RequestsUiState s) => s.copyWith(
            isLoadingAll: false,
            allRequests: result.items,
            allPaging: PagingState.after(result),
          ));
    } catch (error) {
      update((RequestsUiState s) => s.copyWith(
            isLoadingAll: false,
            allError: requestErrorMessage(error, RequestAction.load, 'No se pudieron cargar las solicitudes.'),
          ));
    }
  }

  /// Filters the requests of every employee.
  void onAllFilterSelected(AllRequestsFilter filter) {
    if (filter == state.allFilter) return;
    update((RequestsUiState s) =>
        s.copyWith(allFilter: filter, allRequests: const <Request>[], allPaging: const PagingState()));
    _loadAll();
  }

  /// Loads the next page of all the requests and adds it at the end of the list.
  Future<void> loadMoreAll() async {
    final RequestsUiState current = state;
    if (!current.allPaging.canLoadMore) return;
    final AllRequestsFilter filter = current.allFilter;
    update((RequestsUiState s) =>
        s.copyWith(allPaging: s.allPaging.copyWith(isLoadingMore: true, loadMoreFailed: false)));
    try {
      final RequestPage result = await getAllRequests.execute(
        status: filter.status,
        page: PagingState.nextPage(current.allRequests.length),
      );
      if (state.allFilter != filter) return;
      update((RequestsUiState s) => s.copyWith(
            allRequests: PagingState.merge(s.allRequests, result),
            allPaging: PagingState.after(result),
          ));
    } catch (_) {
      if (state.allFilter != filter) return;
      update((RequestsUiState s) =>
          s.copyWith(allPaging: s.allPaging.copyWith(isLoadingMore: false, loadMoreFailed: true)));
    }
  }
}
