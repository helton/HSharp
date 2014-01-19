unit HSharp.Proxy.Interfaces;

interface

uses
  HSharp.Behaviour.Interfaces;

type
  IProxyStrategy<T> = interface(IInvokable)
    ['{CE969732-65CB-401C-A9C5-3E164762B5C3}']
    function GetInstance: T;
    property Instance: T read GetInstance;
  end;

  IProxy<T> = interface(IProxyStrategy<T>)
    ['{FDD5E9BF-A538-40F5-BDC1-FF4C5180D69B}']
    procedure SetProxyStrategy(aProxyStrategy: IProxyStrategy<T>);
    procedure SetCurrentBehaviour(aBehaviour: IBehaviour<T>);
    procedure AddBehaviour(aBehaviour: IBehaviour<T>);
  end;

implementation

end.
