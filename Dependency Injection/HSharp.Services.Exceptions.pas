unit HSharp.Services.Exceptions;

interface

uses
  System.SysUtils;

type
  ENotRegisteredType<I: IInterface> = class(Exception)
  public
    constructor Create;
  end;

  ETypeAlreadyRegistered<I: IInterface> = class(Exception)
  public
    constructor Create;
  end;

implementation

uses
  System.Rtti,
  System.TypInfo;

{ ENotRegisteredType }

constructor ENotRegisteredType<I>.Create;
begin
  inherited Create(Format('Type not registered yet to interface "%s"',
                   [PTypeInfo(TypeInfo(I)).Name]));
end;

{ ETypeAlreadyRegistered<I> }

constructor ETypeAlreadyRegistered<I>.Create;
begin
  inherited Create(Format('Type already registered to interface "%s"',
                   [PTypeInfo(TypeInfo(I)).Name]));
end;

end.
