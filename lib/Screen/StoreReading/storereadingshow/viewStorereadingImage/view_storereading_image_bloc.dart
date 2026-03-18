import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'view_storereading_image_event.dart';
part 'view_storereading_image_state.dart';

class ViewStorereadingImageBloc extends Bloc<ViewStorereadingImageEvent, ViewStorereadingImageState> {
  ViewStorereadingImageBloc() : super(ViewStorereadingImageInitial()) {
    on<ViewStorereadingImageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
