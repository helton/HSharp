unit HSharp.Container.Exceptions;

interface

uses
  System.TypInfo,
  System.SysUtils;

type
  ENotRegisteredType = class(Exception)
  public
    constructor Create(aTypeInfo: PTypeInfo); reintroduce;
  end;

  ETypeAlreadyRegistered = class(Exception)
  public
    constructor Create(aTypeInfo: PTypeInfo); reintroduce;
  end;

implementation

uses
  System.Rtti;

{ ENotRegisteredType }

constructor ENotRegisteredType.Create(aTypeInfo: PTypeInfo);
begin
  inherited Create(Format('Type not registered yet to interface "%s"',
                   [aTypeInfo.Name]));
end;

{ ETypeAlreadyRegistered }

constructor ETypeAlreadyRegistered.Create(aTypeInfo: PTypeInfo);
begin
  inherited Create(Format('Type already registered to interface "%s"',
                   [aTypeInfo.Name]));
end;

end.
