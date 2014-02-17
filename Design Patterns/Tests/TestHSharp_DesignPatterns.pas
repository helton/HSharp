unit TestHSharp_DesignPatterns;

interface

uses
  TestFramework,
  HSharp.DesignPatterns.Singleton;

type
  TMyClass = class
  end;

  TestSingleton = class(TTestCase)
  published
    procedure WhenCallInstance_ShouldGetAValidInstance;
    procedure WhenCallInstanceTwice_ShouldReturnTheSameInstance;
  end;

implementation


{ TestSingleton }

procedure TestSingleton.WhenCallInstanceTwice_ShouldReturnTheSameInstance;
var
  S: Singleton<TMyClass>;
  Instance1, Instance2: TMyClass;
begin
  Instance1 := S.Instance;
  Instance2 := S.Instance;
  CheckSame(Instance1, Instance2, 'Singleton 2 diferent instance in 2 calls');
end;

procedure TestSingleton.WhenCallInstance_ShouldGetAValidInstance;
var
  S: Singleton<TMyClass>;
begin
  CheckNotNull(S.Instance, 'Singleton returned a nil instance');
end;

initialization
  RegisterTest('HSharp.DesignPatterns.Singleton', TestSingleton.Suite);

end.

