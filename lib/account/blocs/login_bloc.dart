




import 'package:film_wise_mobile/account/data/auth_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/login_model.dart';
import '../data/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBLoc extends Bloc<LoginEvent,LoginState>{
 final LoginRepo  repo;
  LoginBLoc(this.repo) : super(LogincalmState()){



  on<LoadLoginEvent>((event,emit) async{
     emit(LoginLoadingState());

     

     //final login =  await repo.getToken();

  /*  if (login.message !=" wrong")
     emit(LoginLoadedState(services: login));
      else{
        emit(LoginErrorState(msg: 'wronng'));
      }*/


  });

  }



  @override
 Future<Login> mapEventToState(LoginTrigerState event)   async {
   emit(LoginLoadingState());
    print("testt");
    final login =  await repo.getToken(event.loginEntity);
if (login.message !="wrong")
     emit(LoginLoadedState(services: login));
      else
        emit(LoginErrorState(msg: 'wronng'));
 
    
  return login;


}


  @override
 Future<Login> createaccount(RegisterTrigerState event)   async {

    print("register");
    
    final RegisterEntity =  await repo.Registerrepo(event.registerEntity);
     emit(LoginLoadedState(services: RegisterEntity));

    
  return RegisterEntity;





}



}