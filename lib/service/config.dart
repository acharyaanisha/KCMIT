class Config{

  // static const String baseUrl = "http://46.250.248.179:5000";
  // static const String baseUrl = "http://192.168.1.65:5000";
  static const String baseUrl = "http://192.168.1.78:5000";
  // static const String baseUrl = "http://kcmit-api.kcmit.edu.np:5000";

  //Authentication
  static const String _studentAuthenticateEndpoint = "api/authenticate/student";
  static const String _facultyAuthenticateEndpoint = "api/authenticate/faculty";
  static const String _parentAuthenticateEndpoint = "api/authenticate/parent";

  static String getStudent() => '$baseUrl/$_studentAuthenticateEndpoint';
  static String getFaculty() => '$baseUrl/$_facultyAuthenticateEndpoint';
  static String getParent() => '$baseUrl/$_parentAuthenticateEndpoint';


  //ProfileView
  static const String _studentProfileEndpoint = "api/student/profile";

  static String getStudentProfile() => '$baseUrl/$_studentProfileEndpoint';

  static const String _parentProfileEndpoint = "api/parent/profile";

  static String getParentProfile() => '$baseUrl/$_parentProfileEndpoint';

  static const String _facultyProfileEndpoint = "api/faculty/profile";

  static String getFacultyProfile() => '$baseUrl/$_facultyProfileEndpoint';


  //  RoutineView
  static const String _studentRoutineEndpoint = "api/routine/view/student/me";

  static String getStudentRoutine() => '$baseUrl/$_studentRoutineEndpoint';

  static const String _facultyRoutineEndpoint = "api/routine/view/faculty/me";

  static String getFacultyRoutine() => '$baseUrl/$_facultyRoutineEndpoint';


  //Change Password
  static const String _studentChangePasswordEndpoint = "api/student/changePassword";

  static String getStudentChangePassword() => '$baseUrl/$_studentChangePasswordEndpoint';

  static const String _parentChangePasswordEndpoint = "api/parent/changePassword";

  static String getParentChangePassword() => '$baseUrl/$_parentChangePasswordEndpoint';

  static const String _facultyChangePasswordEndpoint = "api/faculty/changePassword";

  static String getFacultyChangePassword() => '$baseUrl/$_facultyChangePasswordEndpoint';

  // Resources
  static const String _studentResourcesEndpoint = "api/resource/viewAll";

  static String getStudentResourcesPassword() => '$baseUrl/$_studentResourcesEndpoint';


  // Faculty Member
  static const String _stFacultyMemberListEndpoint = "api/faculty/list";

  static String getStFacultyMemberList() => '$baseUrl/$_stFacultyMemberListEndpoint';

  // Notices
  static const String _stNoticesEndpoint = "api/notice/viewAll";

  static String getStNotices() => '$baseUrl/$_stNoticesEndpoint';

  //Student List
  static const String _studentListEndpoint = "api/parent/list/students";

  static String getStudentList() => '$baseUrl/$_studentListEndpoint';

  static const String _studentViewEndpoint = "api/parent/view/student";

  static String getStudentView() => '$baseUrl/$_studentViewEndpoint';

  //Exam List
  static const String _examListEndpoint = "api/exam/list";

  static String getExamList() => '$baseUrl/$_examListEndpoint';

  //Student Profile Change
  static const String _stuploadProfileEndpoint = "api/student/uploadProfilePicture";

  static String getStUploadProfile() => '$baseUrl/$_stuploadProfileEndpoint';
}