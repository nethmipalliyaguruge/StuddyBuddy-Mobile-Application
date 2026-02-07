import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  // For Chrome/Web: use localhost
  // For Android emulator: use 10.0.2.2:8000
  // For physical device: use your PC's IP (e.g., 10.2.4.8)
  static const String baseUrl = 'http://localhost:8000/api';

  // // Hosted Laravel backend
  // static const String baseUrl = 'http://52.221.236.102/api';

  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _storageService.deleteToken();
        }
        return handler.next(error);
      },
    ));
  }

  // ==================== AUTH ENDPOINTS ====================

  Future<Response> login(String email, String password) async {
    return await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> logout() async {
    return await _dio.post('/logout');
  }

  Future<Response> getUser() async {
    return await _dio.get('/user');
  }

  Future<Response> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    return await _dio.put('/user', data: {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    });
  }

  // ==================== PUBLIC ENDPOINTS ====================

  Future<Response> getSchools() async {
    return await _dio.get('/schools');
  }

  Future<Response> getSchool(int id) async {
    return await _dio.get('/schools/$id');
  }

  Future<Response> getLevels({int? schoolId}) async {
    final queryParams = <String, dynamic>{};
    if (schoolId != null) queryParams['school_id'] = schoolId;
    return await _dio.get('/levels', queryParameters: queryParams);
  }

  Future<Response> getLevel(int id) async {
    return await _dio.get('/levels/$id');
  }

  Future<Response> getModules({int? levelId}) async {
    final queryParams = <String, dynamic>{};
    if (levelId != null) queryParams['level_id'] = levelId;
    return await _dio.get('/modules', queryParameters: queryParams);
  }

  Future<Response> getModule(int id) async {
    return await _dio.get('/modules/$id');
  }

  Future<Response> getMaterials({
    int? schoolId,
    int? levelId,
    int? moduleId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': 100, // Get all materials in one request (API defaults to 15)
    };
    if (schoolId != null) queryParams['school_id'] = schoolId;
    if (levelId != null) queryParams['level_id'] = levelId;
    if (moduleId != null) queryParams['module_id'] = moduleId;
    if (search != null) queryParams['search'] = search;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (sort != null) queryParams['sort'] = sort;
    return await _dio.get('/materials', queryParameters: queryParams);
  }

  Future<Response> getMaterial(int id) async {
    return await _dio.get('/materials/$id');
  }

  // ==================== PROTECTED ENDPOINTS ====================

  // Notes
  Future<Response> getMyNotes() async {
    return await _dio.get('/my-notes');
  }

  Future<Response> createNote(Map<String, dynamic> data) async {
    return await _dio.post('/notes', data: data);
  }

  Future<Response> createNoteWithFile({
    required String title,
    required String description,
    required int moduleId,
    required double price,
    String? filePath,
    String? previewImagePath,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'module_id': moduleId,
      'price': price,
      if (filePath != null) 'file': await MultipartFile.fromFile(filePath),
      if (previewImagePath != null)
        'preview_image': await MultipartFile.fromFile(previewImagePath),
    });
    return await _dio.post('/notes', data: formData);
  }

  Future<Response> updateNote(int id, Map<String, dynamic> data) async {
    return await _dio.put('/notes/$id', data: data);
  }

  Future<Response> deleteNote(int id) async {
    return await _dio.delete('/notes/$id');
  }

  // Purchases
  Future<Response> getMyPurchases() async {
    return await _dio.get('/my-purchases');
  }

  Future<Response> getPurchase(int id) async {
    return await _dio.get('/purchases/$id');
  }

  // Cart
  Future<Response> getCartItems(List<int> cartIds) async {
    return await _dio.post('/cart', data: {'cart_ids': cartIds});
  }

  Future<Response> validateCartItem(int noteId) async {
    return await _dio.get('/cart/validate/$noteId');
  }

  Future<Response> checkout(List<int> materialIds) async {
    return await _dio.post('/checkout', data: {'material_ids': materialIds});
  }
}
