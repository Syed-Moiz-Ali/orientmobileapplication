import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<Map<String, dynamic>> {}

void main() {
  late MockDio dio;
  late AuthRemoteDatasource datasource;

  setUp(() {
    dio = MockDio();
    datasource = AuthRemoteDatasource(dio);
  });

  group('authenticate', () {
    test('returns Success with parsed AuthResult on 200', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'token': 'jwt-token',
        'refreshToken': 'refresh-token',
        'role': 'advisor',
      });
      when(() => dio.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => response);

      final result = await datasource.authenticate(
        username: 'user',
        password: 'pass',
      );

      expect(result, isA<Success<AuthResult>>());
      result.when(
        success: (data) {
          expect(data.token, 'jwt-token');
          expect(data.refreshToken, 'refresh-token');
          expect(data.role, UserRole.advisor);
        },
        failure: (_) => fail('expected success'),
      );
    });

    test('returns Success with default role when role is missing', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'token': 'jwt'});
      when(() => dio.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => response);

      final result = await datasource.authenticate(
        username: 'u',
        password: 'p',
      );

      expect(result, isA<Success<AuthResult>>());
      result.when(
        success: (data) {
          expect(data.role, UserRole.owner);
          expect(data.refreshToken, isNull);
        },
        failure: (_) => fail('expected success'),
      );
    });

    test('returns Failure on DioException with server message', () async {
      final errorResponse = MockResponse();
      when(() => errorResponse.data).thenReturn({'message': 'Bad credentials'});

      when(() => dio.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: errorResponse,
      ));

      final result = await datasource.authenticate(
        username: 'u',
        password: 'p',
      );

      expect(result, isA<Failure<AuthResult>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) {
          expect((error as NetworkException).message, 'Bad credentials');
        },
      );
    });

    test('returns Failure on DioException without server message', () async {
      when(() => dio.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        message: 'Connection timeout',
      ));

      final result = await datasource.authenticate(
        username: 'u',
        password: 'p',
      );

      expect(result, isA<Failure<AuthResult>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) {
          expect((error as NetworkException).message, 'Connection timeout');
        },
      );
    });

    test('returns Failure on generic exception', () async {
      when(() => dio.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenAnswer((_) => Future.error(Exception('unexpected')));

      final result = await datasource.authenticate(
        username: 'u',
        password: 'p',
      );

      expect(result, isA<Failure<AuthResult>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) {
          expect((error as NetworkException).message, contains('unexpected'));
        },
      );
    });
  });

  group('refreshToken', () {
    test('returns Success with parsed AuthResult on 200', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'token': 'new-jwt',
        'refreshToken': 'new-refresh',
        'role': 'owner',
      });
      when(() => dio.post(
            '/auth/refresh',
            data: any(named: 'data'),
          )).thenAnswer((_) async => response);

      final result = await datasource.refreshToken('old-refresh');

      expect(result, isA<Success<AuthResult>>());
      result.when(
        success: (data) {
          expect(data.token, 'new-jwt');
          expect(data.refreshToken, 'new-refresh');
          expect(data.role, UserRole.owner);
        },
        failure: (_) => fail('expected success'),
      );
    });

    test('returns Failure on DioException', () async {
      final errorResponse = MockResponse();
      when(() => errorResponse.data).thenReturn({'message': 'Token expired'});

      when(() => dio.post(
            '/auth/refresh',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: errorResponse,
      ));

      final result = await datasource.refreshToken('expired');

      expect(result, isA<Failure<AuthResult>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) {
          expect((error as NetworkException).message, 'Token expired');
        },
      );
    });
  });
}
