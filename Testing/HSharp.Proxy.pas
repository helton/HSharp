{***************************************************************************}
{                                                                           }
{           HSharp Framework for Delphi                                     }
{                                                                           }
{           Copyright (C) 2014 Helton Carlos de Souza                       }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit HSharp.Proxy;

interface

uses
  System.Generics.Collections,
  System.Rtti,
  HSharp.Behaviour.Interfaces,
  HSharp.Proxy.Interfaces,
  HSharp.WeakReference;

type
  TBaseProxy<T> = class(TInterfacedObject, IProxy<T>)
  strict private
    FProxyStrategy: IProxyStrategy<T>;
    FBehaviours: TList<IBehaviour<T>>;
    FCurrentBehaviour: IBehaviour<T>;
  private
    function GetInstance: T;
  public
    constructor Create;
    procedure SetProxyStrategy(aProxyStrategy: IProxyStrategy<T>);
    procedure SetCurrentBehaviour(aBehaviour: IBehaviour<T>);
    destructor Destroy; override;
  public
    procedure AddBehaviour(aBehaviour: IBehaviour<T>);
  end;

  TInterfaceProxy<T> = class(TVirtualInterface, IProxyStrategy<T>)
  strict private
    FProxy: Weak<IProxy<T>>;
  private
    procedure DoInvoke(aMethod: TRttiMethod; const aArgs: TArray<TValue>; out aResult: TValue);
  public
    constructor Create(aProxy: IProxy<T>);
    function GetInstance: T;
  end;

  TObjectProxy<T> = class(TInterfacedObject, IProxyStrategy<T>)
  strict private
    FProxy: Weak<IProxy<T>>;
    FInstance: T;
    FInitialized: Boolean;
    FInterceptor: TVirtualMethodInterceptor;
  private
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

procedure TBaseProxy<T>.SetCurrentBehaviour(aBehaviour: IBehaviour<T>);
begin
  FCurrentBehaviour := aBehaviour;
end;

procedure TBaseProxy<T>.SetProxyStrategy(aProxyStrategy: IProxyStrategy<T>);
begin
  FProxyStrategy := aProxyStrategy;
end;

{ TInterfaceProxy<T> }

constructor TInterfaceProxy<T>.Create(aProxy: IProxy<T>);
begin
  inherited Create(TypeInfo(T), DoInvoke);
  FProxy := aProxy;
end;

procedure TInterfaceProxy<T>.DoInvoke(aMethod: TRttiMethod;
  const aArgs: TArray<TValue>; out aResult: TValue);
begin

end;

function TInterfaceProxy<T>.GetInstance: T;
begin
  Supports(Self, GetTypeData(TypeInfo(T)).Guid, Result);
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
  FProxy := aProxy;
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
      FInterceptor.OnBefore := OnBeforeMethodCall;
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


end.
