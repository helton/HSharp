unit HSharp.Proxy;

interface

uses
  System.Generics.Collections,
  System.Rtti,
  HSharp.Proxy.Interfaces,
  HSharp.Behaviour.Interfaces;

type
  TBaseProxy<T> = class(TInterfacedObject, IProxy<T>)
  strict private
    FProxyStrategy: IProxyStrategy<T>;
    FBehaviours: TList<IBehaviour<T>>;
  private
    function GetInstance: T;
  public
    constructor Create;
    procedure SetProxyStrategy(aProxyStrategy: IProxyStrategy<T>);
    destructor Destroy; override;
  public
    procedure AddBehaviour(aBehaviour: IBehaviour<T>);
  end;

  TInterfaceProxy<T> = class(TVirtualInterface, IProxyStrategy<T>)
  strict private
//  [Weak] FProxy: IProxy<T>; //change to a real weak reference
    FProxy: Pointer;
  private
    function Proxy: IProxy<T>;
    procedure DoInvoke(aMethod: TRttiMethod; const aArgs: TArray<TValue>; out aResult: TValue);
  public
    constructor Create(aProxy: IProxy<T>);
    function GetInstance: T;
  end;

  TObjectProxy<T> = class(TInterfacedObject, IProxyStrategy<T>)
  strict private
//  [Weak] FProxy: IProxy<T>; //change to a real weak reference
    FProxy: Pointer;
    FInstance: T;
    FInitialized: Boolean;
    FInterceptor: TVirtualMethodInterceptor;
  private
    function Proxy: IProxy<T>;
    function InstanceAsObject: TObject;
    procedure OnBeforeMethodCall(aInstance: TObject; aMethod: TRttiMethod;
      const aArgs: TArray<TValue>; out aDoInvoke: Boolean; out aResult: TValue);
  public
    constructor Create(aProxy: IProxy<T>);
    destructor Destroy; override;
    function GetInstance: T;
  end;

  TProxyFactory<T> = class
    class function GetProxy: IProxy<T>;
  end;

implementation

uses
  System.TypInfo,
  System.SysUtils,
  HSharp.Exceptions;

{ TBaseProxy<T> }

procedure TBaseProxy<T>.AddBehaviour(aBehaviour: IBehaviour<T>);
begin
  FBehaviours.Add(aBehaviour);
end;

constructor TBaseProxy<T>.Create;
begin
  inherited;
  FBehaviours := TList<IBehaviour<T>>.Create;
end;

destructor TBaseProxy<T>.Destroy;
begin
  FBehaviours.Free;
  inherited;
end;

function TBaseProxy<T>.GetInstance: T;
begin
  Result := FProxyStrategy.Instance;
end;

procedure TBaseProxy<T>.SetProxyStrategy(aProxyStrategy: IProxyStrategy<T>);
begin
  FProxyStrategy := aProxyStrategy;
end;

{ TProxyVirtualInterface<T> }

constructor TInterfaceProxy<T>.Create(aProxy: IProxy<T>);
begin
  inherited Create(TypeInfo(T), DoInvoke);
  FProxy := @aProxy;
end;

procedure TInterfaceProxy<T>.DoInvoke(aMethod: TRttiMethod;
  const aArgs: TArray<TValue>; out aResult: TValue);
begin

end;

function TInterfaceProxy<T>.GetInstance: T;
begin
  Supports(Self, GetTypeData(TypeInfo(T)).Guid, Result);
end;

function TInterfaceProxy<T>.Proxy: IProxy<T>;
begin
  Result := IProxy<T>(FProxy^);
end;

{ TProxyFactory<T> }

class function TProxyFactory<T>.GetProxy: IProxy<T>;
var
  Proxy: IProxy<T>;
begin
  Proxy := TBaseProxy<T>.Create;
  case TRttiContext.Create.GetType(TypeInfo(T)).TypeKind of
    tkInterface:
      Proxy.SetProxyStrategy(TInterfaceProxy<T>.Create(Proxy));
    tkClass:
      Proxy.SetProxyStrategy(TObjectProxy<T>.Create(Proxy));
    else
      EUnsupportedParameterizedType.Create('The specified generic parameter type is not an interface or a class');
  end;
  Result := Proxy;
end;

{ TObjectProxy<T> }

constructor TObjectProxy<T>.Create(aProxy: IProxy<T>);
begin
  inherited Create;
  FProxy := @aProxy;
end;

destructor TObjectProxy<T>.Destroy;
begin
  if FInitialized then
  begin
    FInterceptor.Unproxify(InstanceAsObject);
    FInterceptor.Free;
    InstanceAsObject.Free;
  end;
  inherited;
end;

function TObjectProxy<T>.GetInstance: T;
var
  RttiType: TRttiType;
begin
  if not FInitialized then
  begin
    RttiType := TRttiContext.Create.GetType(TypeInfo(T));
    if not Assigned(RttiType) then
      ENoRttiFound.Create('No RTTI found to specified parameterized type')
    else
    begin
      FInstance    := RttiType.GetMethod('Create').Invoke(RttiType.AsInstance.MetaclassType, []).AsType<T>;
      FInterceptor := TVirtualMethodInterceptor.Create(RttiType.AsInstance.MetaclassType);
      FInterceptor.Proxify(InstanceAsObject);
      Finterceptor.OnBefore := OnBeforeMethodCall;
    end;
    FInitialized := True;
  end;
  Result := FInstance;
end;

function TObjectProxy<T>.InstanceAsObject: TObject;
begin
  Result := TObject(Pointer(@FInstance)^);
end;

procedure TObjectProxy<T>.OnBeforeMethodCall(aInstance: TObject;
  aMethod: TRttiMethod; const aArgs: TArray<TValue>; out aDoInvoke: Boolean;
  out aResult: TValue);
begin

end;

function TObjectProxy<T>.Proxy: IProxy<T>;
begin
  Result := IProxy<T>(FProxy^);
end;

end.
