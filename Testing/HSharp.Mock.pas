unit HSharp.Mock;

interface

uses
  System.Rtti,
  HSharp.Mock.Interfaces,
  HSharp.Proxy.Interfaces,
  HSharp.Proxy;

type
  TWhen<T> = class(TInterfacedObject, IWhen<T>)
  strict private
    FProxy: IProxy<T>;
  public
    constructor Create(aProxy: IProxy<T>); reintroduce;
    function When: T;
  end;

  TSetup<T> = class(TInterfacedObject, ISetup<T>)
  strict private
    FProxy: IProxy<T>;
    FWhen: IWhen<T>;
  public
    constructor Create(aProxy: IProxy<T>); reintroduce;
    function WillReturn(aValue: TValue): IWhen<T>;
  end;

  TMock<T> = class(TInterfacedObject, IMock<T>)
  strict private
    FProxy: IProxy<T>;
    FSetup: ISetup<T>;
  private
    function GetInstance: T;
  public
    constructor Create;
    property Instance: T read GetInstance;
    property Setup: ISetup<T> read FSetup;
  end;

implementation

uses
  System.SysUtils;

{ TMock<T> }

constructor TMock<T>.Create;
begin
  inherited;
  FProxy := TProxyFactory<T>.GetProxy;
  FSetup := TSetup<T>.Create(FProxy);
end;

function TMock<T>.GetInstance: T;
begin
  Result := FProxy.Instance;
end;

{ TSetup<T> }

constructor TSetup<T>.Create(aProxy: IProxy<T>);
begin
  inherited Create;
  FProxy := aProxy;
  FWhen  := TWhen<T>.Create(aProxy);
end;

function TSetup<T>.WillReturn(aValue: TValue): IWhen<T>;
begin
  Result := FWhen;
end;

{ TWhen<T> }

constructor TWhen<T>.Create(aProxy: IProxy<T>);
begin
  inherited Create;
  FProxy := aProxy;
end;

function TWhen<T>.When: T;
begin
  Result := FProxy.Instance;
end;

end.
