unit HSharp.Services;

interface

uses
  HSharp.Collections.Interfaces,
  HSharp.Collections;

type
  TServiceLocator = class
  strict private
    FTypesDict: IDictionary<TGuid, TClass>;
  protected
    function InterfaceToGuid<I: IInterface>: TGuid;
  public
    constructor Create;
    procedure Clear;
    function HasType<I: IInterface>: Boolean;
    procedure RegisterType<I: IInterface; T: class, constructor>;
    function ResolveType<I: IInterface>: I;
    procedure UnregisterType<I: IInterface>;
  end;

var
  ServiceLocator: TServiceLocator;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  HSharp.Services.Exceptions;

{ TServiceLocator }

procedure TServiceLocator.Clear;
begin
  FTypesDict.Clear;
end;

constructor TServiceLocator.Create;
begin
  inherited;
  FTypesDict := Collections.CreateDictionary<TGuid, TClass>;
end;

function TServiceLocator.HasType<I>: Boolean;
begin
  Result := FTypesDict.ContainsKey(InterfaceToGuid<I>);
end;

function TServiceLocator.InterfaceToGuid<I>: TGuid;
begin
  Result := GetTypeData(TypeInfo(I)).Guid;
end;

procedure TServiceLocator.RegisterType<I, T>;
begin
  if not FTypesDict.ContainsKey(InterfaceToGuid<I>) then
    FTypesDict.Add(InterfaceToGuid<I>, T)
  else
    raise ETypeAlreadyRegistered<I>.Create;
end;

function TServiceLocator.ResolveType<I>: I;
var
  Clazz: TClass;
begin
  if FTypesDict.TryGetValue(InterfaceToGuid<I>, Clazz) then
    Supports(Clazz.Create, InterfaceToGuid<I>, Result)
  else
    raise ENotRegisteredType<I>.Create;
end;

procedure TServiceLocator.UnregisterType<I>;
begin
  if FTypesDict.ContainsKey(InterfaceToGuid<I>) then
    FTypesDict.Remove(InterfaceToGuid<I>)
  else
    raise ENotRegisteredType<I>.Create;
end;

initialization
  ServiceLocator := TServiceLocator.Create;
finalization
  ServiceLocator.Free;

end.
