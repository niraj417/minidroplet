// abstract class EbookDetailEvent {}
//
// class FetchEbookDetail extends EbookDetailEvent {
//   final int ebookId;
//   FetchEbookDetail(this.ebookId);
// }
//
// class CreateOrder extends EbookDetailEvent {
//   final int ebookId;
//   CreateOrder(this.ebookId);
// }
//
// class UpdateRating extends EbookDetailEvent {
//   final double rating;
//   UpdateRating(this.rating);
// }
//
// class LoadPrefData extends EbookDetailEvent {}
//
// // ebook_detail_state.dart
// class EbookDetailState {
//   final List<EbookDetailDataModel> allEbookItems;
//   final bool isAllEbookLoading;
//   final bool isPaymentLoading;
//   final double rating;
//
//   // Detail data
//   final String? ebookName;
//   final String? description;
//   final String? image;
//   final String? authorName;
//   final String? page;
//   final String? price;
//   final String? mainPrice;
//   final String? audio;
//   final int? totalReview;
//   final String? preview;
//
//   // Payment data
//   final String? orderId;
//   final String? amount;
//   final String? name;
//   final String? contact;
//   final String? email;
//
//   EbookDetailState({
//     this.allEbookItems = const [],
//     this.isAllEbookLoading = true,
//     this.isPaymentLoading = false,
//     this.rating = 0.0,
//     this.ebookName,
//     this.description,
//     this.image,
//     this.authorName,
//     this.page,
//     this.price,
//     this.mainPrice,
//     this.audio,
//     this.totalReview,
//     this.preview,
//     this.orderId,
//     this.amount,
//     this.name,
//     this.contact,
//     this.email,
//   });
//
//   EbookDetailState copyWith({
//     List<EbookDetailDataModel>? allEbookItems,
//     bool? isAllEbookLoading,
//     bool? isPaymentLoading,
//     double? rating,
//     String? ebookName,
//     String? description,
//     String? image,
//     String? authorName,
//     String? page,
//     String? price,
//     String? mainPrice,
//     String? audio,
//     int? totalReview,
//     String? preview,
//     String? orderId,
//     String? amount,
//     String? name,
//     String? contact,
//     String? email,
//   }) {
//     return EbookDetailState(
//       allEbookItems: allEbookItems ?? this.allEbookItems,
//       isAllEbookLoading: isAllEbookLoading ?? this.isAllEbookLoading,
//       isPaymentLoading: isPaymentLoading ?? this.isPaymentLoading,
//       rating: rating ?? this.rating,
//       ebookName: ebookName ?? this.ebookName,
//       description: description ?? this.description,
//       image: image ?? this.image,
//       authorName: authorName ?? this.authorName,
//       page: page ?? this.page,
//       price: price ?? this.price,
//       mainPrice: mainPrice ?? this.mainPrice,
//       audio: audio ?? this.audio,
//       totalReview: totalReview ?? this.totalReview,
//       preview: preview ?? this.preview,
//       orderId: orderId ?? this.orderId,
//       amount: amount ?? this.amount,
//       name: name ?? this.name,
//       contact: contact ?? this.contact,
//       email: email ?? this.email,
//     );
//   }
// }
//
// // ebook_detail_bloc.dart
// class EbookDetailBloc extends Bloc<EbookDetailEvent, EbookDetailState> {
//   final DioClient dioClient = GetIt.instance<DioClient>();
//   final PaymentService _paymentService = sl<PaymentService>();
//
//   EbookDetailBloc() : super(EbookDetailState()) {
//     on<FetchEbookDetail>(_onFetchEbookDetail);
//     on<CreateOrder>(_onCreateOrder);
//     on<UpdateRating>(_onUpdateRating);
//     on<LoadPrefData>(_onLoadPrefData);
//   }
//
//   Future<void> _onFetchEbookDetail(
//       FetchEbookDetail event,
//       Emitter<EbookDetailState> emit,
//       ) async {
//     CommonMethods.devLog(logName: 'Ebook id', message: event.ebookId);
//     try {
//       final response = await dioClient.sendPostRequest(
//         ApiEndpoints.ebookDetail,
//         {"ebook_id": event.ebookId},
//       );
//
//       if (response.data['status'] == 1) {
//         final data = EbookDetailModel.fromJson(response.data);
//         CommonMethods.devLog(logName: 'Ebook detail', message: data.data);
//
//         if (data.data != null) {
//           emit(state.copyWith(
//             ebookName: data.data!.title,
//             description: data.data!.description,
//             image: data.data!.coverImage,
//             authorName: data.data!.authorName,
//             page: data.data!.pages,
//             price: data.data!.price,
//             mainPrice: data.data!.mainPrice,
//             audio: data.data!.audio,
//             totalReview: data.data!.totalReview,
//             preview: data.data!.preview,
//             allEbookItems: [data.data!],
//             isAllEbookLoading: false,
//           ));
//         }
//       } else {
//         emit(state.copyWith(isAllEbookLoading: false));
//         print('Failed to load data: ${response.data['message']}');
//       }
//     } catch (e) {
//       emit(state.copyWith(isAllEbookLoading: false));
//       print('Error fetching ebook detail data: $e');
//     }
//   }
//
//   Future<void> _onCreateOrder(
//       CreateOrder event,
//       Emitter<EbookDetailState> emit,
//       ) async {
//     emit(state.copyWith(isPaymentLoading: true));
//
//     CommonMethods.devLog(logName: 'Ebook id', message: event.ebookId);
//     try {
//       final response = await dioClient.sendPostRequest(
//         ApiEndpoints.createOrder,
//         {"ebook_id": event.ebookId},
//       );
//
//       if (response.data['status'] == 1) {
//         final data = response.data['data'];
//         CommonMethods.devLog(
//             logName: 'Create payment order id', message: data['order_id']);
//
//         emit(state.copyWith(
//           orderId: data['order_id'],
//           amount: data['amount'],
//           isPaymentLoading: false,
//         ));
//
//         CommonMethods.devLog(logName: 'Assigned order id', message: state.orderId);
//       } else {
//         emit(state.copyWith(isPaymentLoading: false));
//         print('Failed to load data: ${response.data['message']}');
//       }
//     } catch (e) {
//       emit(state.copyWith(isPaymentLoading: false));
//       print('Error fetching create order detail data: $e');
//     }
//   }
//
//   void _onUpdateRating(
//       UpdateRating event,
//       Emitter<EbookDetailState> emit,
//       ) {
//     emit(state.copyWith(rating: event.rating));
//   }
//
//   void _onLoadPrefData(
//       LoadPrefData event,
//       Emitter<EbookDetailState> emit,
//       ) {
//     final prefData = SharedPref.getLoginData();
//     emit(state.copyWith(
//       name: prefData?.data?.name ?? '',
//       contact: prefData?.data?.mobile ?? '',
//       email: prefData?.data?.email ?? '',
//     ));
//   }
//
//   @override
//   Future<void> close() {
//     _paymentService.dispose();
//     return super.close();
//   }
// }
//
// // ebook_buy_detail_page.dart
// class EbookBuyDetailPage extends StatelessWidget {
//   final int ebookId;
//
//   const EbookBuyDetailPage({super.key, required this.ebookId});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => EbookDetailBloc()
//         ..add(FetchEbookDetail(ebookId))
//         ..add(CreateOrder(ebookId))
//         ..add(LoadPrefData()),
//       child: const EbookBuyDetailView(),
//     );
//   }
// }
//
// class EbookBuyDetailView extends StatelessWidget {
//   const EbookBuyDetailView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<EbookDetailBloc, EbookDetailState>(
//       builder: (context, state) {
//         return Scaffold(
//           extendBodyBehindAppBar: true,
//           bottomSheet: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             color: Theme.of(context).scaffoldBackgroundColor,
//             height: 80,
//             child: _buildPaymentButton(context, state),
//           ),
//           appBar: const NormalAppBar(),
//           body: RefreshIndicator(
//             onRefresh: () async {
//               context.read<EbookDetailBloc>().add(
//                 FetchEbookDetail(context.read<EbookDetailBloc>().ebookId),
//               );
//             },
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   BookPaletteCard(
//                     imagePath: state.image ?? DummyData.avatarUrl,
//                     onPressed: () {
//                       if (state.preview != null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 PdfViewerPage(pdfUrl: state.preview!),
//                           ),
//                         );
//                       } else {
//                         CommonMethods.showSnackBar(
//                             context, 'No Preview available');
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   StarRating(
//                     rating: 3.5,
//                     allowHalfRating: true,
//                     color: const Color(AppColor.primaryColor),
//                     onRatingChanged: (rating) => context
//                         .read<EbookDetailBloc>()
//                         .add(UpdateRating(rating)),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 20),
//                         Text(
//                           state.ebookName ?? 'No data',
//                           style: const TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           state.authorName ?? 'No data',
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                         const SizedBox(height: 20),
//                         _buildBookReview(state),
//                         const SizedBox(height: 20),
//                         Text(
//                           state.description ?? 'No data',
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                         const SizedBox(height: 150),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBookReview(EbookDetailState state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Column(
//           children: [
//             const Text(
//               'Audio',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               state.audio ?? 'Not available',
//               style: const TextStyle(fontSize: 13),
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 40,
//           child: VerticalDivider(
//             thickness: 2,
//             color: Colors.grey.shade300,
//           ),
//         ),
//         Column(
//           children: [
//             Text(
//               state.page ?? 'No data',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               'Pages',
//               style: TextStyle(fontSize: 13),
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 40,
//           child: VerticalDivider(
//             thickness: 2,
//             color: Colors.grey.shade300,
//           ),
//         ),
//         Column(
//           children: [
//             Text(
//               state.totalReview?.toString() ?? '0',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               "Reviews",
//               style: TextStyle(fontSize: 13),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentButton(BuildContext context, EbookDetailState state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Price",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 22,
//               ),
//             ),
//             Text(
//               CommonMethods.formatRupees(state.amount ?? ''),
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 22,
//               ),
//             ),
//           ],
//         ),
//         AppButton(
//           useCupertino: true,
//           width: 180,
//           text: 'Buy Now',
//           onPressed: () {
//             if (state.amount != null &&
//                 state.orderId != null &&
//                 state.name != null &&
//                 state.contact != null &&
//                 state.email != null) {
//               goto(
//                 context,
//                 CheckoutPage(
//                   ebookId: context.read<EbookDetailBloc>().ebookId,
//                   orderId: state.orderId!,
//                   ebookCover: state.image ?? '',
//                   ebookName: state.ebookName ?? '',
//                   authorName: state.authorName ?? '',
//                   totalPage: state.page ?? '',
//                   audio: state.audio ?? '',
//                   amount: state.price ?? '',
//                   discountPercentage: '10',
//                   mainPrice: state.mainPrice ?? '0',
//                   name: state.name ?? '',
//                   contact: state.contact ?? '',
//                   email: state.email ?? '',
//                 ),
//               );
//             } else {
//               CommonMethods.showSnackBar(
//                   context, "Something went wrong, Please try again later");
//             }
//           },
//         ),
//       ],
//     );
//   }
// }