import 'package:streambeats/services/db/dao/search_history_dao.dart';

class SearchRepository {
  final SearchHistoryDAO _searchHistoryDao;

  const SearchRepository(this._searchHistoryDao);

  Future<void> saveSearchQuery(String query) =>
      _searchHistoryDao.putSearchHistory(query);

  Future<List<Map<String, String>>> getRecentSearches({int limit = 10}) =>
      _searchHistoryDao.getLastSearches(limit: limit);

  Future<List<Map<String, String>>> getSuggestions(String query) =>
      _searchHistoryDao.getSimilarSearches(query);

  Future<void> removeSearchEntry(String id) =>
      _searchHistoryDao.removeSearchHistory(id);

  Future<void> clearSearchHistory() =>
      _searchHistoryDao.clearAllSearchHistory();

  Future<void> trimHistory() => _searchHistoryDao.limitSearchHistory();
}