//
//
// import '../../../../../core/constant/app_export.dart';
// import '../model/saved_item_model.dart';
//
// @immutable
// abstract class SavedItemsState {
//   const SavedItemsState();
// }
//
// class SavedItemsInitial extends SavedItemsState {}
//
// class SavedItemsLoading extends SavedItemsState {}
//
// class SavedItemsLoaded extends SavedItemsState {
//   final List<SavedItemDataModel> ebooks;
//   final List<SavedItemDataModel> videos;
//   final List<SavedItemDataModel> playlists;
//
//   const SavedItemsLoaded({
//     required this.ebooks,
//     required this.videos,
//     required this.playlists,
//   });
//
//   SavedItemsLoaded copyWith({
//     List<SavedItemDataModel>? ebooks,
//     List<SavedItemDataModel>? videos,
//     List<SavedItemDataModel>? playlists,
//   }) {
//     return SavedItemsLoaded(
//       ebooks: ebooks ?? this.ebooks,
//       videos: videos ?? this.videos,
//       playlists: playlists ?? this.playlists,
//     );
//   }
// }
//
// class SavedItemsError extends SavedItemsState {
//   final String message;
//   const SavedItemsError(this.message);
// }