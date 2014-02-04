unit HSharp.Patterns.UnitOfWork;

interface

uses
  System.Rtti,
  HSharp.Core.Arrays;

type
  TUnitOfWork = class
    function IsLoaded<T: class, constructor>(const AKeys: TArray<TValue>): Boolean;
    function Get<T: class, constructor>(const AKeys: TArray<TValue>): T;
  end;

implementation

{ TUnitOfWork }

function TUnitOfWork.Get<T>(const AKeys: TArray<TValue>): T;
begin

end;

function TUnitOfWork.IsLoaded<T>(const AKeys: TArray<TValue>): Boolean;
begin

end;

end.
