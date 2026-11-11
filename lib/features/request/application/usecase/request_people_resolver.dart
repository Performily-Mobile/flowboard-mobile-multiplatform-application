import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/entity/request_person.dart';
import 'package:flowboard/features/request/domain/repository/request_employee_directory.dart';

/// Completes the names of the requester, the approver and the history actors of the requests.
///
/// When Workspace fails the requests are returned as they are, with their default names.
class RequestPeopleResolver {
  /// Creates the resolver.
  const RequestPeopleResolver({required this.directory});

  final RequestEmployeeDirectory directory;

  /// Requests of [requests] with their people.
  Future<List<Request>> resolveAll(List<Request> requests) async {
    if (requests.isEmpty) return requests;
    final Map<int, RequestPerson> people = await _people();
    return requests.map((Request request) => _withPeople(request, people)).toList();
  }

  /// [request] with its people.
  Future<Request> resolve(Request request) async => (await resolveAll(<Request>[request])).first;

  /// Requests of [page] with their people.
  Future<RequestPage> resolvePage(RequestPage page) async => page.withItems(await resolveAll(page.items));

  Future<Map<int, RequestPerson>> _people() async {
    try {
      final List<RequestPerson> people = await directory.getPeople();
      return <int, RequestPerson>{for (final RequestPerson person in people) person.id: person};
    } catch (_) {
      return <int, RequestPerson>{};
    }
  }

  Request _withPeople(Request request, Map<int, RequestPerson> people) {
    final int? approverId = request.approverEmployeeId;
    return request.withPeople(
      requester: people[request.requesterId],
      approver: approverId == null ? null : people[approverId],
      history: request.history.map((RequestHistoryEntry entry) {
        final int? actorId = entry.actorId;
        return entry.withActorName(actorId == null ? null : people[actorId]?.name);
      }).toList(),
    );
  }
}
