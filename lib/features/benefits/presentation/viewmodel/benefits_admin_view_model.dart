import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/benefits/application/usecase/change_benefit_type_status_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/create_benefit_type_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_assignments_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_benefit_types_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/register_delivery_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/presentation/state/benefits_admin_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_error_messages.dart';

/// View model of the HR benefits screen (MA-60, MA-62).
///
/// It manages the catalog (US37) and the assignments with the delivery registration (US39).
class BenefitsAdminViewModel extends ViewModel<BenefitsAdminUiState> {
  /// Creates the view model and loads both tabs.
  BenefitsAdminViewModel({
    required this.getBenefitTypes,
    required this.createBenefitType,
    required this.changeBenefitTypeStatus,
    required this.getAssignments,
    required this.registerDelivery,
  }) : super(const BenefitsAdminUiState()) {
    load();
  }

  final GetBenefitTypesUseCase getBenefitTypes;
  final CreateBenefitTypeUseCase createBenefitType;
  final ChangeBenefitTypeStatusUseCase changeBenefitTypeStatus;
  final GetAssignmentsUseCase getAssignments;
  final RegisterDeliveryUseCase registerDelivery;

  static const int _maxNotes = 250;

  int _catalogRequest = 0;
  int _assignmentsRequest = 0;

  /// Loads both tabs; reloads never hide the data that is already visible.
  void load() {
    _loadCatalog();
    _loadAssignments();
  }

  /// Selects the tab [index] (0 catalog, 1 assignments).
  void onTabSelected(int index) => update((BenefitsAdminUiState s) => s.copyWith(selectedTab: index));

  /// Shows the outcome of the assign benefit screen in the assignments tab.
  void onAssignmentResult(String message) {
    update((BenefitsAdminUiState s) => s.copyWith(
          selectedTab: 1,
          assignmentFilter: AssignmentStatus.assigned,
          snackbarMessage: message,
        ));
    _loadAssignments();
  }

  /// Loads the catalog (MA-60); with data on screen a failure is reported with a snackbar.
  Future<void> _loadCatalog() async {
    final int request = ++_catalogRequest;
    update((BenefitsAdminUiState s) => s.copyWith(isLoadingCatalog: s.benefitTypes.isEmpty, catalogError: null));
    try {
      final List<BenefitType> types = await getBenefitTypes.execute();
      if (request != _catalogRequest) return;
      update((BenefitsAdminUiState s) => s.copyWith(isLoadingCatalog: false, benefitTypes: types));
    } catch (error) {
      if (request != _catalogRequest) return;
      final String message = benefitsMessage(error, BenefitsAction.load, 'No se pudo cargar el catálogo.');
      update((BenefitsAdminUiState s) => s.benefitTypes.isEmpty
          ? s.copyWith(isLoadingCatalog: false, catalogError: message)
          : s.copyWith(isLoadingCatalog: false, snackbarMessage: message));
    }
  }

  /// Opens an empty new type form.
  void showTypeSheet() =>
      update((BenefitsAdminUiState s) => s.copyWith(isTypeSheetVisible: true, typeForm: const BenefitTypeForm()));

  /// Closes the new type form.
  void dismissTypeSheet() => update((BenefitsAdminUiState s) => s.copyWith(isTypeSheetVisible: false));

  /// Changes the name of the new type.
  void onTypeNameChange(String value) =>
      update((BenefitsAdminUiState s) => s.copyWith(typeForm: s.typeForm.copyWith(name: value, nameError: null)));

  /// Changes the unit of the new type.
  void onTypeUnitChange(BenefitUnit unit) =>
      update((BenefitsAdminUiState s) => s.copyWith(typeForm: s.typeForm.copyWith(unit: unit)));

  /// Marks whether the new type tracks a balance.
  void onTypeHasBalanceChange(bool value) =>
      update((BenefitsAdminUiState s) => s.copyWith(typeForm: s.typeForm.copyWith(hasBalance: value)));

  /// Creates the benefit type; a duplicated name is flagged on the field before calling the backend.
  Future<void> saveType() async {
    final BenefitTypeForm form = state.typeForm;
    if (form.isSaving) return;
    final String name = form.name.trim().toLowerCase();
    if (state.benefitTypes.any((BenefitType type) => type.name.toLowerCase() == name)) {
      update((BenefitsAdminUiState s) =>
          s.copyWith(typeForm: form.copyWith(nameError: 'Ya existe un beneficio con este nombre.')));
      return;
    }
    update((BenefitsAdminUiState s) => s.copyWith(typeForm: form.copyWith(isSaving: true)));
    try {
      final BenefitType type = await createBenefitType.execute(form.name, form.unit, form.hasBalance);
      update((BenefitsAdminUiState s) => s.copyWith(
            isTypeSheetVisible: false,
            typeForm: s.typeForm.copyWith(isSaving: false),
            snackbarMessage: 'Beneficio "${type.name}" creado.',
          ));
      _loadCatalog();
    } catch (error) {
      update((BenefitsAdminUiState s) => s.copyWith(
            typeForm: s.typeForm.copyWith(
              isSaving: false,
              nameError: benefitsMessage(error, BenefitsAction.createType, 'No se pudo crear el beneficio.'),
            ),
          ));
    }
  }

  /// Opens the confirmation to activate or deactivate [type].
  void requestToggleType(BenefitType type) => update((BenefitsAdminUiState s) => s.copyWith(typeToToggle: type));

  /// Closes the confirmation.
  void dismissToggleType() => update((BenefitsAdminUiState s) => s.copyWith(typeToToggle: null));

  /// Activates or deactivates the type of the open confirmation.
  Future<void> confirmToggleType() async {
    final BenefitType? type = state.typeToToggle;
    if (type == null || state.isTogglingType) return;
    update((BenefitsAdminUiState s) => s.copyWith(isTogglingType: true));
    try {
      final BenefitType updated = await changeBenefitTypeStatus.execute(type);
      update((BenefitsAdminUiState s) => s.copyWith(
            isTogglingType: false,
            typeToToggle: null,
            benefitTypes: s.benefitTypes.map((BenefitType item) => item.id == updated.id ? updated : item).toList(),
            snackbarMessage: updated.active ? '"${updated.name}" activado.' : '"${updated.name}" desactivado.',
          ));
    } catch (error) {
      update((BenefitsAdminUiState s) => s.copyWith(
            isTogglingType: false,
            typeToToggle: null,
            snackbarMessage: benefitsMessage(error, BenefitsAction.changeTypeStatus, 'No se pudo cambiar el estado.'),
          ));
    }
  }

  /// Changes the assignments filter (MA-62) and reloads the list.
  void onFilterSelected(AssignmentStatus status) {
    if (status == state.assignmentFilter) return;
    update((BenefitsAdminUiState s) =>
        s.copyWith(assignmentFilter: status, assignments: const <BenefitAssignment>[]));
    _loadAssignments();
  }

  /// Loads the assignments of the current filter.
  ///
  /// An answer is ignored when a newer request started meanwhile. With data on screen a failure is
  /// reported with a snackbar instead of hiding it.
  Future<void> _loadAssignments() async {
    final int request = ++_assignmentsRequest;
    final AssignmentStatus filter = state.assignmentFilter;
    update((BenefitsAdminUiState s) =>
        s.copyWith(isLoadingAssignments: s.assignments.isEmpty, assignmentsError: null));
    try {
      final List<BenefitAssignment> assignments = await getAssignments.execute(filter);
      if (request != _assignmentsRequest) return;
      update((BenefitsAdminUiState s) => s.copyWith(isLoadingAssignments: false, assignments: assignments));
    } catch (error) {
      if (request != _assignmentsRequest) return;
      final String message = benefitsMessage(error, BenefitsAction.load, 'No se pudieron cargar las asignaciones.');
      update((BenefitsAdminUiState s) => s.assignments.isEmpty
          ? s.copyWith(isLoadingAssignments: false, assignmentsError: message)
          : s.copyWith(isLoadingAssignments: false, snackbarMessage: message));
    }
  }

  /// Opens the delivery dialog of [assignment].
  ///
  /// A delivery can be neither before the validity start nor in the future, so when the validity
  /// has not started yet no valid date exists and a snackbar explains it instead.
  void showDeliveryDialog(BenefitAssignment assignment) {
    if (!assignment.canBeDelivered) return;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    if (assignment.startDate.isAfter(today)) {
      update((BenefitsAdminUiState s) => s.copyWith(
            snackbarMessage: 'La vigencia de este beneficio empieza el ${BenefitsFormatters.date(assignment.startDate)}. '
                'Aún no se puede registrar su entrega.',
          ));
      return;
    }
    update((BenefitsAdminUiState s) => s.copyWith(deliveryForm: DeliveryForm(assignment: assignment, deliveredOn: today)));
  }

  /// Closes the delivery dialog.
  void dismissDeliveryDialog() => update((BenefitsAdminUiState s) => s.copyWith(deliveryForm: null));

  /// Changes the delivery date.
  void onDeliveryDateChange(DateTime date) =>
      update((BenefitsAdminUiState s) => s.copyWith(deliveryForm: s.deliveryForm?.copyWith(deliveredOn: date, error: null)));

  /// Changes the delivery notes, up to 250 characters.
  void onDeliveryNotesChange(String value) => update((BenefitsAdminUiState s) => s.copyWith(
        deliveryForm: s.deliveryForm?.copyWith(notes: value.length > _maxNotes ? value.substring(0, _maxNotes) : value),
      ));

  /// Registers the delivery of the assignment of the open dialog.
  ///
  /// The answer of the POST lacks the employee name, so the one of the assignment is used.
  Future<void> confirmDelivery() async {
    final DeliveryForm? form = state.deliveryForm;
    if (form == null || form.isSaving) return;
    update((BenefitsAdminUiState s) => s.copyWith(deliveryForm: form.copyWith(isSaving: true, error: null)));
    try {
      final BenefitAssignment delivered = await registerDelivery.execute(form.assignment, form.deliveredOn, form.notes);
      update((BenefitsAdminUiState s) => s.copyWith(
            deliveryForm: null,
            assignments: s.assignments.where((BenefitAssignment item) => item.id != delivered.id).toList(),
            snackbarMessage: 'Entrega registrada: ${form.assignment.benefitTypeName} para '
                '${form.assignment.employeeName} el ${BenefitsFormatters.date(form.deliveredOn)}.',
          ));
    } catch (error) {
      update((BenefitsAdminUiState s) => s.copyWith(
            deliveryForm: s.deliveryForm?.copyWith(
              isSaving: false,
              error: benefitsMessage(error, BenefitsAction.deliver, 'No se pudo registrar la entrega.'),
            ),
          ));
    }
  }

  /// Clears the snackbar message once it was shown.
  void onSnackbarShown() => update((BenefitsAdminUiState s) => s.copyWith(snackbarMessage: null));
}
