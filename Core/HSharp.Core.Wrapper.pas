unit HSharp.Core.Wrapper;

interface

type
  IWrapper<T> = interface
    ['{B8BF7123-1FCE-4452-B68C-893FFF378DDE}']
    function GetInstance: T;
    procedure SetInstance(const Value: T);
    property Instance: T read GetInstance write SetInstance;
  end;

  TWrapper<T> = class(TInterfacedObject, IWrapper<T>)
  strict private
    FInstance: T;
  strict protected
    function GetInstance: T;
    procedure SetInstance(const Value: T);
  end;

implementation

{ TWrapper<T> }

function TWrapper<T>.GetInstance: T;
begin
  Result := FInstance;
end;

procedure TWrapper<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
end;

end.
