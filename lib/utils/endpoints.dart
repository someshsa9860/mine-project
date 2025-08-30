const domain = 'mine.solvebyai.in';
const url = 'https://$domain/api';
const domainUrl = 'https://$domain';

class EndPoints {
  static const loginApi = '/login';
  static const createTokenApi = '/create-token';
  static const getTokenApi = '/token/find';
  static const deleteTokenApi = '/token';
  static const getTripsApi = '/trips/latest';
  static const exitTripApi = '/exit-trip';
  static const initDataApi = '/dashboard';
  static const reportsPdfApi = '/generate-report-pdf';
  static const reportsViewApi = '/view-report-data';
  static const recentTokenApi = '/recent/tokens';
}
