unit HSharp.Container.Impl;

interface

uses
  System.Rtti,
  System.TypInfo,
  HSharp.Collections.Interfaces,
  HSharp.Collections,
  HSharp.Container.Types,
  HSharp.Container.Interfaces;

type
  TContainer = class;

  TContainerHandler = class abstract(TInterfacedObject)
  strict private
    FContainer: TContainer;
  protected
    property Container: TContainer read FContainer;
  public
    constructor Create(aContainer: TContainer); reintroduce;
  end;

  TRegistrationInfo = class(TInterfacedObject, IRegistrationInfo)
  strict private
    FInstance: TValue;
    FClassTypeInfo: PTypeInfo;
    FClassImpl: TClass;
    FIntfGuid: TGuid;
    FActivatorDelegate: TActivatorDelegate<TObject>;
    FLifetime: TLifetimeType;
  protected
    property ClassTypeInfo: PTypeInfo read FClassTypeInfo;
    property ClassImpl: TClass read FClassImpl;
    property IntfGuid: TGuid read FIntfGuid;
    property ActivatorDelegate: TActivatorDelegate<TObject> read FActivatorDelegate;
    property Lifetime: TLifetimeType read FLifetime;
  public
    constructor Create(aClassTypeInfo: PTypeInfo; aClassImpl: TClass;
                       aIntfGuid: TGuid; aActivatorDelegate: TActivatorDelegate<TObject>;
                       aLifetime: TLifetimeType); reintroduce;
    function GetInstance: TValue;
  end;

  TImplementsType<T: class, constructor> = class(TContainerHandler, IImplementsType<T>)
  strict private
    FIntfGuid: TGuid;
  public
    { IImplementsType<T> }
    procedure AsTransient;
    procedure AsSingleton;
    procedure DelegateTo(const aDelegate: TActivatorDelegate<T>);
  public
    property IntfGuid: TGuid read FIntfGuid;
    constructor Create(aContainer: TContainer; aIntfGuid: TGuid); reintroduce;
  end;

  TRegistrationType<T: class, constructor> = class(TContainerHandler, IRegistrationType<T>)
  public
    { IRegistrationType<T> }
    function Implements(aIntfGuid: TGuid): IImplementsType<T>;
  end;

  TContainer = class
  strict private
    FTypesDict: IDictionary<TGuid, IRegistrationInfo>;
  private
    function InterfaceToGuid<I: IInterface>: TGuid;
  protected
    procedure AddRegistrationInfo(aGuid: TGuid; aRegistrationInfo: TRegistrationInfo);
  public
    constructor Create;
    procedure Reset;
    function HasType<I: IInterface>: Boolean;
    function RegisterType<T: class, constructor>: IRegistrationType<T>;
    function ResolveType<I: IInterface>: I;
    procedure UnregisterType<I: IInterface>;
  end;

implementation

uses
  System.SysUtils,
  HSharp.Container.Exceptions;

{ TContainer }

function TContainer.RegisterType<T>: IRegistrationType<T>;
begin
  Result := TRegistrationType<T>.Create(Self);
end;

procedure TContainer.Reset;
begin
  FTypesDict.Clear;
end;

procedure TContainer.AddRegistrationInfo(aGuid: TGuid;
  aRegistrationInfo: TRegistrationInfo);
begin
  if not FTypesDict.ContainsKey(aGuid) then
    FTypesDict.Add(aGuid, aRegistrationInfo)
  else
    raise ETypeAlreadyRegistered.Create(aRegistrationInfo.ClassTypeInfo);
end;

constructor TContainer.Create;
begin
  inherited;
  FTypesDict := Collections.CreateDictionary<TGuid, IRegistrationInfo>;
end;

function TContainer.HasType<I>: Boolean;
begin
  Result := FTypesDict.ContainsKey(InterfaceToGuid<I>);
end;

function TContainer.InterfaceToGuid<I>: TGuid;
begin
  Result := GetTypeData(TypeInfo(I)).Guid;
end;

function TContainer.ResolveType<I>: I;
var
  RegistrationInfo: IRegistrationInfo;
begin
  if FTypesDict.TryGetValue(InterfaceToGuid<I>, RegistrationInfo) then
    Result := RegistrationInfo.GetInstance.AsType<I>
    //Supports(Clazz.Create, InterfaceToGuid<I>, Result)
  else
    raise ENotRegisteredType.Create(TypeInfo(I));
end;

procedure TContainer.UnregisterType<I>;
begin
  if FTypesDict.ContainsKey(InterfaceToGuid<I>) then
    FTypesDict.Remove(InterfaceToGuid<I>)
  else
    raise ENotRegisteredType.Create(TypeInfo(I));
end;

{ TContainerHolder }

constructor TContainerHandler.Create(aContainer: TContainer);
begin
  inherited Create;
  FContainer := aContainer;
end;

{ TRegistrationInfo }

constructor TRegistrationInfo.Create(aClassTypeInfo: PTypeInfo;
  aClassImpl: TClass; aIntfGuid: TGuid; aActivatorDelegate: TActivatorDelegate<TObject>;
  aLifetime: TLifetimeType);
begin
  inherited Create;
  FClassTypeInfo     := aClassTypeInfo;
  FClassImpl         := aClassImpl;
  FIntfGuid          := aIntfGuid;
  FActivatorDelegate := aActivatorDelegate;
  FLifetime          := aLifetime;
  FInstance          := TValue.Empty;
end;

function TRegistrationInfo.GetInstance: TValue;
var
  Data: TObject;
begin
  case Lifetime of
    Singleton:
      begin
        if FInstance.IsEmpty then
        begin
          Data := ClassImpl.Create;
          TValue.Make(@Data, ClassTypeInfo, FInstance);
        end;
        Result := FInstance;
      end;
    Transient:
      begin
        Data := ClassImpl.Create;
        TValue.Make(@Data, ClassTypeInfo, Result);
      end;
    Delegation:
      begin
        Data := ActivatorDelegate;
        TValue.Make(@Data, ClassTypeInfo, Result);
      end;
  end;
end;

{ TRegistrationType<T> }

function TRegistrationType<T>.Implements(aIntfGuid: TGuid): IImplementsType<T>;
begin
  Result := TImplementsType<T>.Create(Container, aIntfGuid);
end;

{ TImplementsType<T> }

procedure TImplementsType<T>.AsSingleton;
var
  RegistrationInfo: TRegistrationInfo;
begin
  RegistrationInfo := TRegistrationInfo.Create(TypeInfo(T), T, IntfGuid, nil, Singleton);
  Container.AddRegistrationInfo(IntfGuid, RegistrationInfo);
end;

procedure TImplementsType<T>.AsTransient;
var
  RegistrationInfo: TRegistrationInfo;
begin
  RegistrationInfo := TRegistrationInfo.Create(TypeInfo(T), T, IntfGuid, nil, Transient);
  Container.AddRegistrationInfo(IntfGuid, RegistrationInfo);
end;

constructor TImplementsType<T>.Create(aContainer: TContainer; aIntfGuid: TGuid);
begin
  inherited Create(aContainer);
  FIntfGuid := aIntfGuid;
end;

procedure TImplementsType<T>.DelegateTo(const aDelegate: TActivatorDelegate<T>);
var
  RegistrationInfo: TRegistrationInfo;
begin
  RegistrationInfo := TRegistrationInfo.Create(TypeInfo(T), T, IntfGuid, TActivatorDelegate<TObject>(aDelegate), Delegation);
  Container.AddRegistrationInfo(IntfGuid, RegistrationInfo);
end;

end.
