unit TestHSharp_Services;

interface

uses
  TestFramework;

type
  TestTServiceLocator = class(TTestCase)
  protected
    procedure SetUp; override;
  published
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
  HSharp.Services,
  HSharp.Services.Exceptions;

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

{ TestTServiceLocator }

procedure TestTServiceLocator.AfterRegisterAType_HasTypeShouldReturnTrue;
begin
  ServiceLocator.RegisterType<ITest, TTest1>;
  CheckTrue(ServiceLocator.HasType<ITest>,
            'ServiceLocator should have a ITest implementation registered');
end;

procedure TestTServiceLocator.AfterUnregisterAType_HasTypeShouldReturnFalse;
begin
  ServiceLocator.RegisterType<ITest, TTest1>;
  ServiceLocator.UnregisterType<ITest>;
  CheckFalse(ServiceLocator.HasType<ITest>,
             'ServiceLocator should''t have a ITest implementation registered anymore');
end;

procedure TestTServiceLocator.BeforeRegisterAType_HasTypeShouldReturnFalse;
begin
  CheckFalse(ServiceLocator.HasType<ITest>,
             'ServiceLocator should''t have a ITest implementation registered yet');
end;

procedure TestTServiceLocator.SetUp;
begin
  inherited;
  ServiceLocator.Clear;
end;

procedure TestTServiceLocator.TryGetAnInterfaceImplementationNotRegisteredYet_ShouldRaiseAnException;
begin
  StartExpectingException(ENotRegisteredType<ITest>);
  ServiceLocator.ResolveType<ITest>;
  StopExpectingException('Try get a interface implementation not registered yet ' +
                         'should raise an exception ENotRegisteredType<I>');
end;

procedure TestTServiceLocator.TryRegisterTwoImplementationsToSameInterface_ShouldRaiseAnException;
begin
  StartExpectingException(ETypeAlreadyRegistered<ITest>);
  ServiceLocator.RegisterType<ITest, TTest1>;
  ServiceLocator.RegisterType<ITest, TTest2>;
  StopExpectingException('Try regiser two implementations to same interface ' +
                         'should raise an exception ETypeAlreadyRegistered<I>');
end;

procedure TestTServiceLocator.TryUnregisterATypeNotRegisteredYet_ShouldRaiseAnException;
begin
  StartExpectingException(ENotRegisteredType<ITest>);
  ServiceLocator.UnregisterType<ITest>;
  StopExpectingException('Try unregister a type not registered yet ' +
                         'should raise an exception ENotRegisteredType<I>');
end;

procedure TestTServiceLocator.AfterRegisterAType_ResolveTypeShouldReturnACorrectInterfaceImplementation;
var
  I: ITest;
begin
  ServiceLocator.RegisterType<ITest, TTest1>;
  I := ServiceLocator.ResolveType<ITest>;
  CheckIs(TObject(I), TTest1,
          'Wrong interface implementation returned after register TTest1 as ' +
          'implementation of ITest');
  CheckEquals('TTest1.Foo called', I.Foo);

  ServiceLocator.UnregisterType<ITest>;

  ServiceLocator.RegisterType<ITest, TTest2>;
  I := ServiceLocator.ResolveType<ITest>;
  CheckIs(TObject(I), TTest2,
          'Wrong interface implementation returned after register TTest2 as ' +
          'implementation of ITest');
  CheckEquals('TTest2.Foo called', I.Foo);
end;

initialization
  RegisterTest('HSharp.Services', TestTServiceLocator.Suite);
end.

