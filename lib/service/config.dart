class Config{

  // static const String baseUrl = "http://46.250.248.179:5000";
  // static const String baseUrl = "http://192.168.1.78:5000";
  static const String baseUrl = "http://kcmit-api.kcmit.edu.np:5000";

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
  static const String _stFacultyMemberListEndpoint = "api/faculty/list/app";
  // static const String _stFacultyMemberListEndpoint = "api/faculty/list";

  static String getStFacultyMemberList() => '$baseUrl/$_stFacultyMemberListEndpoint';

  // Notices
  static const String _stNoticesEndpoint = "api/notice/list/app";

  static String getStNotices() => '$baseUrl/$_stNoticesEndpoint';

  //Student List
  static const String _studentListEndpoint = "api/parent/list/students";

  static String getStudentList() => '$baseUrl/$_studentListEndpoint';

  static const String _studentViewEndpoint = "api/parent/view/student";

  static String getStudentView() => '$baseUrl/$_studentViewEndpoint';

  //Exam List
  static const String _examListEndpoint = "api/result/student/exam";

  static String getExamList() => '$baseUrl/$_examListEndpoint';

  //Student Profile Change
  static const String _stuploadProfileEndpoint = "api/student/uploadProfilePicture";

  static String getStUploadProfile() => '$baseUrl/$_stuploadProfileEndpoint';

  //Events
  static const String _eventEndpoint = "api/event/list";

  static String getEvent() => '$baseUrl/$_eventEndpoint';

  static const String _studentEventEndpoint = "api/event/listForStudent";

  static String getStudentEvent() => '$baseUrl/$_studentEventEndpoint';

  static const String _facultyEventEndpoint = "api/event/listForFaculty";

  static String getFacultyEvent() => '$baseUrl/$_facultyEventEndpoint';

  // Result View Student
  static const String _resultEndpoint = "api/result/student/view";

  static String getResult() => '$baseUrl/$_resultEndpoint';

  // Course View Student
  static const String _viewCourseEndpoint = "api/course/view/student/me";

  static String getCourse() => '$baseUrl/$_viewCourseEndpoint';

  // Thread View Student
  static const String _viewThreadEndpoint = "api/thread/student/view";

  static String getThreadView() => '$baseUrl/$_viewThreadEndpoint';

  static const String _postThreadEndpoint = "api/thread/student/post";

  static String getThreadPost() => '$baseUrl/$_postThreadEndpoint';

  static const String _commentThreadEndpoint = "api/thread/student/comment";

  static String getThreadComment() => '$baseUrl/$_commentThreadEndpoint';

  static const String _viewCommentThreadEndpoint = "api/thread/comments";

  static String getThreadCommentView() => '$baseUrl/$_viewCommentThreadEndpoint';

  static const String _likeThreadEndpoint = "api/thread/student/like";

  static String getThreadLike() => '$baseUrl/$_likeThreadEndpoint';

  static const String _viewOneThreadEndpoint = "api/thread/view";

  static String getThreadViewComment() => '$baseUrl/$_viewOneThreadEndpoint';

  // Thread Faculty
  static const String _viewSemesterEndpoint = "api/faculty/view/coursesAndSemester";

  static String getSemester() => '$baseUrl/$_viewSemesterEndpoint';

  static const String _threadViewEndpoint = "api/thread/faculty/view";

  static String getThread() => '$baseUrl/$_threadViewEndpoint';

  static const String _ThreadpostEndpoint = "api/thread/faculty/post";

  static String getPostThread() => '$baseUrl/$_ThreadpostEndpoint';
  //
  static const String _commentThreadFacEndpoint = "api/thread/faculty/comment";

  static String getThreadCommentFac() => '$baseUrl/$_commentThreadFacEndpoint';
  //
  static const String _viewCommentThreadFacEndpoint = "api/thread/comments";

  static String getThreadCommentViewFac() => '$baseUrl/$_viewCommentThreadFacEndpoint';

  static const String _likeThreadFacultyEndpoint = "api/thread/faculty/like";

  static String getThreadLikeFaculty() => '$baseUrl/$_likeThreadFacultyEndpoint';

  static const String _viewOneThreadFacEndpoint = "api/thread/faculty/me";

  static String getThreadViewCommentFac() => '$baseUrl/$_viewOneThreadFacEndpoint';

  // Exam View Routine
  static const String _viewexamEndpoint = "api/examSetup/viewRoutine";

  static String getExam() => '$baseUrl/$_viewexamEndpoint';
}