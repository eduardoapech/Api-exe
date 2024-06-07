import 'package:api_dados/models/filter_model.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

setupLocator() {
  // Registrar uma instância padrão do FilterModel
  getIt.registerLazySingleton<FilterModel>(() => FilterModel());

  // Registrar uma instância nomeada do FilterModel
  getIt.registerLazySingleton<FilterModel>(() => FilterModel(), instanceName: 'filterInstance');
}

final filtroPessoa = getIt<FilterModel>();