class ApiConfig {
  ApiConfig._();

  /// 后端 API 基础地址
  /// 开发环境使用 localhost，部署时改为生产地址
  static const String baseUrl = 'http://localhost:8080/v1';

  /// 生产环境 API 地址（部署时切换）
  static const String productionBaseUrl = 'https://api.picflow.app/v1';

  static const int pageSize = 20;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}