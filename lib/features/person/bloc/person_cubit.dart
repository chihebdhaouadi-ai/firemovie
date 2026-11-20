import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/person_repository.dart';
import '../domain/person.dart';

sealed class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object?> get props => [];
}

final class PersonLoading extends PersonState {
  const PersonLoading();
}

final class PersonFailed extends PersonState {
  const PersonFailed();
}

final class PersonLoaded extends PersonState {
  const PersonLoaded(this.person);

  final PersonDetail person;

  @override
  List<Object?> get props => [person];
}

class PersonCubit extends Cubit<PersonState> {
  PersonCubit({required this.personId, required PersonRepository repository})
      : _repository = repository,
        super(const PersonLoading());

  final String personId;
  final PersonRepository _repository;

  Future<void> load() async {
    emit(const PersonLoading());
    try {
      final person = await _repository.fetchPerson(personId);
      if (!isClosed) emit(PersonLoaded(person));
    } on Exception {
      if (!isClosed) emit(const PersonFailed());
    }
  }
}
