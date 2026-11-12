import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_download_link.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/infrastructure/mapper/payroll_mapper.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payslip_dto.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payslip_service.dart';

/// Payslips read from and written to the Flowboard API.
class PayslipRepositoryImpl implements PayslipRepository {
  /// Creates the repository.
  const PayslipRepositoryImpl({required this.service});

  final PayslipService service;

  @override
  Future<List<Payslip>> getPayslipsByPeriod(int payrollPeriodId) async {
    final List<PayslipDto> dtos = await service.getPayslipsByPayrollPeriod(payrollPeriodId);
    return dtos.map(PayrollMapper.toPayslip).toList();
  }

  @override
  Future<Payslip> uploadPayslip(
    EmployeeId employeeId,
    int payrollPeriodId,
    FileReference file,
    DateTime issueDate,
    Money netAmount,
  ) async {
    final PayslipFileRequestDto request = PayrollMapper.toFileRequest(
      file,
      issueDate,
      netAmount,
      employeeId: employeeId,
      payrollPeriodId: payrollPeriodId,
    );
    return PayrollMapper.toPayslip(await service.uploadPayslip(request));
  }

  @override
  Future<Payslip> replaceFile(int payslipId, FileReference file, DateTime issueDate, Money netAmount) async {
    final PayslipFileRequestDto request = PayrollMapper.toFileRequest(file, issueDate, netAmount);
    return PayrollMapper.toPayslip(await service.replacePayslipFile(payslipId, request));
  }

  @override
  Future<Payslip> markAsPaid(int payslipId, DateTime paidOn) async {
    return PayrollMapper.toPayslip(await service.markAsPaid(payslipId, PayrollMapper.isoDate(paidOn)));
  }

  @override
  Future<Payslip> markAsObserved(int payslipId, String reason) async {
    return PayrollMapper.toPayslip(await service.markAsObserved(payslipId, reason));
  }

  @override
  Future<List<Payslip>> getMyPayslips(EmployeeId employeeId, int year) async {
    final List<PayslipDto> dtos = await service.getMyPayslips(employeeId.value, year);
    return dtos.map(PayrollMapper.toPayslip).toList();
  }

  @override
  Future<PayslipDetail> getMyPayslip(EmployeeId employeeId, int payslipId) async {
    return PayrollMapper.toDetail(await service.getMyPayslip(employeeId.value, payslipId));
  }

  @override
  Future<PayslipDownloadLink> getMyPayslipDownloadLink(EmployeeId employeeId, int payslipId) async {
    return PayrollMapper.toDownloadLink(await service.getMyPayslipDownloadUrl(employeeId.value, payslipId));
  }
}
