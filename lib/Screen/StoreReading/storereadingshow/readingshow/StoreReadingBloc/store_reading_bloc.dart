import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'store_reading_event.dart';
part 'store_reading_state.dart';

class StoreReadingBloc extends Bloc<StoreReadingEvent, StoreReadingState> {
  StoreReadingBloc() : super(StoreReadingInitial()) {
    on<StoreReadingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
