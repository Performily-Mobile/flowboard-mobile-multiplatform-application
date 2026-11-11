import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_sort_order.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';

const Object _keep = Object();

/// Tabs of the requests screen.
enum RequestsTab {
  mine,
  toApprove,
  hrInbox,
  all;

  /// Tabs shown to [role].
  static List<RequestsTab> forRole(UserRole role) => switch (role) {
        UserRole.employee => const <RequestsTab>[RequestsTab.mine, RequestsTab.toApprove],
        UserRole.humanResources => const <RequestsTab>[RequestsTab.hrInbox, RequestsTab.all],
      };
}

/// Filter of the viewer's own requests.
enum MyRequestsFilter {
  all('Todas', null),
  pending('Pendientes', RequestStatus.inProgress),
  underReview('En revisión', RequestStatus.underReview),
  approved('Aprobadas', RequestStatus.approved),
  rejected('Rechazadas', RequestStatus.rejected);

  const MyRequestsFilter(this.label, this.status);

  final String label;
  final RequestStatus? status;
}

/// Filter of the requests of every employee.
enum AllRequestsFilter {
  pending('Pendientes', RequestStatus.inProgress),
  underReview('En revisión', RequestStatus.underReview),
  approved('Aprobadas', RequestStatus.approved),
  rejected('Rechazadas', RequestStatus.rejected);

  const AllRequestsFilter(this.label, this.status);

  final String label;
  final RequestStatus status;
}

/// Order of the requests to approve.
enum ApprovalSort {
  oldestFirst('Más antiguas primero', RequestSortOrder.oldestFirst),
  newestFirst('Más recientes primero', RequestSortOrder.newestFirst);

  const ApprovalSort(this.label, this.order);

  final String label;
  final RequestSortOrder order;
}

/// Reason typed before rejecting a request from the list.
class RejectForm {
  /// Creates the form.
  const RejectForm({required this.request, this.reason = '', this.error, this.isSaving = false});

  final Request request;
  final String reason;
  final String? error;
  final bool isSaving;

  /// Copy with the given values replaced.
  RejectForm copyWith({String? reason, Object? error = _keep, bool? isSaving}) {
    return RejectForm(
      request: request,
      reason: reason ?? this.reason,
      error: identical(error, _keep) ? this.error : error as String?,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// State of the requests screen: own requests, requests to approve, HR inbox and all requests.
class RequestsUiState {
  /// Creates the state.
  const RequestsUiState({
    this.role = UserRole.employee,
    this.viewerId = 0,
    this.selectedTab = RequestsTab.mine,
    this.isLoadingMine = false,
    this.myRequests = const <Request>[],
    this.mineError,
    this.myFilter = MyRequestsFilter.all,
    this.minePaging = const PagingState(),
    this.isLoadingPending = false,
    this.pending = const <Request>[],
    this.pendingTotal = 0,
    this.pendingPaging = const PagingState(),
    this.pendingError,
    this.requestTypes = const <RequestType>[],
    this.typeFilter,
    this.sort = ApprovalSort.oldestFirst,
    this.processingRequestId,
    this.rejectForm,
    this.isLoadingAll = false,
    this.allRequests = const <Request>[],
    this.allError,
    this.allFilter = AllRequestsFilter.pending,
    this.allPaging = const PagingState(),
    this.snackbarMessage,
  });

  final UserRole role;
  final int viewerId;
  final RequestsTab selectedTab;

  final bool isLoadingMine;
  final List<Request> myRequests;
  final String? mineError;
  final MyRequestsFilter myFilter;
  final PagingState minePaging;

  final bool isLoadingPending;
  final List<Request> pending;
  final int pendingTotal;
  final PagingState pendingPaging;
  final String? pendingError;
  final List<RequestType> requestTypes;
  final RequestType? typeFilter;
  final ApprovalSort sort;
  final int? processingRequestId;
  final RejectForm? rejectForm;

  final bool isLoadingAll;
  final List<Request> allRequests;
  final String? allError;
  final AllRequestsFilter allFilter;
  final PagingState allPaging;

  final String? snackbarMessage;

  /// Tabs shown to the role of the viewer.
  List<RequestsTab> get tabs => RequestsTab.forRole(role);

  /// True when the viewer can approve or reject [request]: nobody resolves their own request.
  bool canResolve(Request request) => request.requesterId != viewerId;

  /// Text of a tab, with the number of pending requests where it applies.
  String tabLabel(RequestsTab tab) => switch (tab) {
        RequestsTab.mine => 'Mías',
        RequestsTab.toApprove => 'Por aprobar ($pendingTotal)',
        RequestsTab.hrInbox => 'RR.HH. ($pendingTotal)',
        RequestsTab.all => 'Todas',
      };

  /// Copy with the given values replaced.
  RequestsUiState copyWith({
    RequestsTab? selectedTab,
    bool? isLoadingMine,
    List<Request>? myRequests,
    Object? mineError = _keep,
    MyRequestsFilter? myFilter,
    PagingState? minePaging,
    bool? isLoadingPending,
    List<Request>? pending,
    int? pendingTotal,
    PagingState? pendingPaging,
    Object? pendingError = _keep,
    List<RequestType>? requestTypes,
    Object? typeFilter = _keep,
    ApprovalSort? sort,
    Object? processingRequestId = _keep,
    Object? rejectForm = _keep,
    bool? isLoadingAll,
    List<Request>? allRequests,
    Object? allError = _keep,
    AllRequestsFilter? allFilter,
    PagingState? allPaging,
    Object? snackbarMessage = _keep,
  }) {
    return RequestsUiState(
      role: role,
      viewerId: viewerId,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoadingMine: isLoadingMine ?? this.isLoadingMine,
      myRequests: myRequests ?? this.myRequests,
      mineError: identical(mineError, _keep) ? this.mineError : mineError as String?,
      myFilter: myFilter ?? this.myFilter,
      minePaging: minePaging ?? this.minePaging,
      isLoadingPending: isLoadingPending ?? this.isLoadingPending,
      pending: pending ?? this.pending,
      pendingTotal: pendingTotal ?? this.pendingTotal,
      pendingPaging: pendingPaging ?? this.pendingPaging,
      pendingError: identical(pendingError, _keep) ? this.pendingError : pendingError as String?,
      requestTypes: requestTypes ?? this.requestTypes,
      typeFilter: identical(typeFilter, _keep) ? this.typeFilter : typeFilter as RequestType?,
      sort: sort ?? this.sort,
      processingRequestId:
          identical(processingRequestId, _keep) ? this.processingRequestId : processingRequestId as int?,
      rejectForm: identical(rejectForm, _keep) ? this.rejectForm : rejectForm as RejectForm?,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      allRequests: allRequests ?? this.allRequests,
      allError: identical(allError, _keep) ? this.allError : allError as String?,
      allFilter: allFilter ?? this.allFilter,
      allPaging: allPaging ?? this.allPaging,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
