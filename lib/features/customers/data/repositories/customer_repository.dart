import 'package:dartz/dartz.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepository(this.remoteDataSource);

  Future<Either<Exception, List<Customer>>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    try {
      final customers = await remoteDataSource.getCustomers(
        page: page,
        limit: limit,
        search: search,
        status: status,
      );
      return Right(customers);
    } catch (e) {
      return Left(Exception('Failed to fetch customers: $e'));
    }
  }

  Future<Either<Exception, Customer>> getCustomerById(String customerId) async {
    try {
      final customer = await remoteDataSource.getCustomerById(customerId);
      return Right(customer);
    } catch (e) {
      return Left(Exception('Failed to fetch customer: $e'));
    }
  }
}

