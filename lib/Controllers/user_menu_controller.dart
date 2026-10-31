import 'package:get/get.dart';
import 'package:ami_student/services/menu_service.dart';

class UserMenuController extends GetxController {
  final MenuService _menuService = MenuService();

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var activeMenu = <String, dynamic>{}.obs;

  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // 🌟 DYNAMIC INITIALIZATION: Auto-detect today's day index (1 = Mon -> index 0, 7 = Sun -> index 6)
  late RxInt selectedDayIndex;

  String get selectedDayKey => days[selectedDayIndex.value];

  @override
  void onInit() {
    super.onInit();
    
    // Set initial index to today's weekday
    int todayWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    selectedDayIndex = (todayWeekday - 1).obs;

    fetchActiveMenu();
  }

  void changeDay(int index) {
    selectedDayIndex.value = index;
  }

  Future<void> fetchActiveMenu() async {
    try {
      isLoading(true);
      errorMessage('');
      final menuData = await _menuService.fetchActiveMenu();
      activeMenu.value = menuData;
    } catch (e) {
      errorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading(false);
    }
  }

  List<String> getMealItems(String mealType) {
    if (activeMenu.isEmpty || activeMenu['weeklySchedule'] == null) {
      return [];
    }
    var dayData = activeMenu['weeklySchedule'][selectedDayKey];
    if (dayData != null && dayData[mealType] != null) {
      return List<String>.from(dayData[mealType]);
    }
    return [];
  }
}