unit HSharp.Container.Interfaces;

interface

uses
  System.Rtti,
  HSharp.Container.Types;

type
  IRegistrationInfo = interface
    ['{585073EE-B872-4563-A0EA-9F0F9076ED4E}']
    function GetInstance: TValue;
  end;

  IImplementsType<T: class, constructor> = interface
    ['{63F2078A-3E7F-4F9A-AC7F-A1F604995AF4}']
    procedure AsTransient;
    procedure AsSingleton;
    procedure DelegateTo(const aDelegate: TActivatorDelegate<T>);
  end;

  IRegistrationType<T: class, constructor> = interface
    ['{198C5BBB-B420-448C-BDBC-7AD3CBF6093C}']
    function Implements(aIntfGuid: TGuid): IImplementsType<T>;
  end;

implementation

end.
