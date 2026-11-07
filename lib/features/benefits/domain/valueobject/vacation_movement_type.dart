/// Reason of a change in the vacation balance.
///
/// [accrual]: days earned (initial and monthly accrual).
/// [usage]: days taken by an approved request.
/// [reversal]: days returned when an approved request is cancelled.
/// [manualAdjustment]: correction made by HR with a reason and an author (US42).
enum VacationMovementType { accrual, usage, reversal, manualAdjustment }
