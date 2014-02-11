unit TestHSharp_Container;

interface

uses
  TestFramework;

type
  TestGlobalContainer = class(TTestCase)
  protected
    procedure SetUp; override;
  published
    procedure AfterRegisterSingletonAndRequestAnInstance_ShouldReturnSameInstance;
    procedure AfterRegisterDelegateAndRequestAnInstance_ShouldCallDelegateMethod;

    procedure AfterRegisterAType_ResolveTypeShouldReturnACorrectInterfaceImplementation;
    procedure BeforeRegisterAType_HasTypeShouldReturnFalse;
    procedure AfterRegisterAType_HasTypeShouldReturnTrue;
    procedure AfterUnregisterAType_HasTypeShouldReturnFalse;
    procedure TryGetAnInterfaceImplementationNotRegisteredYet_ShouldRaiseAnException;
    procedure TryUnregisterATypeNotRegisteredYet_ShouldRaiseAnException;
    procedure TryRegisterTwoImplementationsToSameInterface_ShouldRaiseAnException;
  end;

implementation

uses
  HSharp.Container,
  HSharp.Container.Exceptions;

type
  ITest = interface
    ['{685733A0-33E2-43BF-AF4D-CDD128559E46}']
    function Foo: string;
  end;

  TTest1 = class(TInterfacedObject, ITest)
  public
    function Foo: string;
  end;

  TTest2 = class(TInterfacedObject, ITest)
  public
    function Foo: string;
  end;

{ TTest1 }

function TTest1.Foo: string;
begin
  Result := 'TTest1.Foo called';
end;

{ TTest2 }

function TTest2.Foo:  string;
begin
  Result := 'TTest2.Foo called';
end;

{ TestTGlobalContainer }

procedure TestGlobalContainer.AfterRegisterAType_HasTypeShouldReturnTrue;
begin
  GlobalContainer.RegisterType<TTest1>.Implements(ITest).AsTransient;
  CheckTrue(GlobalContainer.HasType<ITest>,
            'GlobalContainer should have a ITest implementation registered');
end;

procedure TestGlobalContainer.AfterUnregisterAType_HasTypeShouldReturnFalse;
begin
  GlobalContainer.RegisterType<TTest1>.Implements(ITest).AsTransient;
  GlobalContainer.UnregisterType<ITest>;
  CheckFalse(GlobalContainer.HasType<ITest>,
             'GlobalContainer should''t have a ITest implementation registered anymore');
end;

procedure TestGlobalContainer.BeforeRegisterAType_HasTypeShouldReturnFalse;
begin
  CheckFalse(GlobalContainer.HasType<ITest>,
             'GlobalContainer should''t have a ITest implementation registered yet');
end;

procedure TestGlobalContainer.SetUp;
begin
  inherited;
  GlobalContainer.Reset;
end;

procedure TestGlobalContainer.AfterRegisterSingletonAndRequestAnInstance_ShouldReturnSameInstance;
var
  ResolvedType1, ResolvedType2: ITest;
begin
  GlobalContainer.RegisterType<TTest1>.Implements(ITest).AsSingleton;
  ResolvedType1 := GlobalContainer.ResolveType<ITest>;
  ResolvedType2 := GlobalContainer.ResolveType<ITest>;
  CheckSame(ResolvedType1, ResolvedType2);
end;

procedure TestGlobalContainer.AfterRegisterDelegateAndRequestAnInstance_ShouldCallDelegateMethod;
var
  ResolvedType: ITest;
  ReturnedValue: ITest;
begin
  GlobalContainer.RegisterType<TTest1>.Implements(ITest).DelegateTo(
    function : TTest1
    begin
      Result := TTest1.Create;
      ReturnedValue := Result;
    end
  );
  ResolvedType := GlobalContainer.ResolveType<ITest>;
  CheckSame(ReturnedValue, ResolvedType);
end;

procedure TestGlobalContainer.TryGetAnInterfaceImplementationNotRegisteredYet_ShouldRaiseAnException;
begin
  StartExpectingException(ENotRegisteredType);
  GlobalContainer.ResolveType<ITest>;
  StopExpectingException('Try get a interface implementation not registered yet ' +
                         'should raise an exception ENotRegisteredType<I>');
end;

procedure TestGlobalContainer.TryRegisterTwoImplementationsToSameInterface_ShouldRaiseAnException;
begin
  StartExpectingException(ETypeAlreadyRegistered);
  GlobalContainer.RegisterType<TTest1>.Implements(ITest).AsTransient;
  GlobalContainer.RegisterType<TTest2>.Implements(ITest).AsTransient;
  StopExpectingException('Try regiser two implementations to same interface ' +
                         'should raise an exception ETypeAlreadyRegistered<I>');
end;

procedure TestGlobalContainer.TryUnregisterATypeNotRegisteredYet_ShouldRaiseAnException;
begin
  StartExpectingException(ENotRegisteredType);
  GlobalContainer.UnregisterType<ITest>;
  StopExpectingException('Try unregister a type not registered yet ' +
                         'should raise an exception ENotRegisteredType<I>');
end;

procedure TestGlobalContainer.AfterRegisterAType_ResolveTypeShouldReturnACorrectInterfaceImplementation;
var
  I: ITest;
begin
  GlobalContainer.RegisterType<TTest1>.Implements(ITest).AsTransient;
  I := GlobalContainer.ResolveType<ITest>;
  CheckIs(TObject(I), TTest1,
          'Wrong interface implementation returned after register TTest1 as ' +
          'implementation of ITest');
  CheckEquals('TTest1.Foo called', I.Foo);

  GlobalContainer.UnregisterType<ITest>;

  GlobalContainer.RegisterType<TTest2>.Implements(ITest).AsTransient;
  I := GlobalContainer.ResolveType<ITest>;
  CheckIs(TObject(I), TTest2,
          'Wrong interface implementation returned after register TTest2 as ' +
          'implementation of ITest');
  CheckEquals('TTest2.Foo called', I.Foo);
end;

initialization
  RegisterTest('HSharp.Container', TestGlobalContainer.Suite);
end.

