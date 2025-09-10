import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/local/preferences_datasource.dart';
import 'data/datasources/local/sqlite_datasource.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/template_repository_impl.dart';
import 'data/repositories/invoice_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/template_repository.dart';
import 'domain/repositories/invoice_repository.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/invoice/create_invoice_usecase.dart';
import 'domain/usecases/invoice/generate_pdf_usecase.dart';
import 'domain/usecases/invoice/calculate_shipping_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/invoice/invoice_bloc.dart';
import 'services/pdf/pdf_generator.dart';
import 'services/shipping/shipping_calculator.dart';
import 'services/ads/admob_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton<PreferencesDatasource>(
    () => PreferencesDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<SqliteDatasource>(
    () => SqliteDatasourceImpl(),
  );
  sl.registerLazySingleton<SupabaseDatasource>(
    () => SupabaseDatasourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<TemplateRepository>(
    () => TemplateRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => CreateInvoiceUsecase(sl()));
  sl.registerLazySingleton(() => GeneratePdfUsecase(sl()));
  sl.registerLazySingleton(() => CalculateShippingUsecase(sl()));

  // Services
  sl.registerLazySingleton(() => PdfGenerator());
  sl.registerLazySingleton(() => ShippingCalculator());
  sl.registerLazySingleton(() => AdMobService.instance);

  // Blocs
  sl.registerFactory(() => AuthBloc(
    sl<LoginUsecase>(),
    sl<RegisterUsecase>(),
    sl<LogoutUsecase>(),
    sl<AuthRepository>(),
  ));
  sl.registerFactory(() => InvoiceBloc(
    sl<CreateInvoiceUsecase>(),
    sl<GeneratePdfUsecase>(),
    sl<InvoiceRepository>(),
  ));
}
