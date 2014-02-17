unit HSharp.DesignPatterns.Singleton;

interface

type
  Singleton<T: class, constructor> = record
  strict private
    FInstance: T;
  private
    function GetInstance: T;
  public
    property Instance: T read GetInstance;
  end;

implementation

{ Singleton<T> }

function Singleton<T>.GetInstance: T;
begin
  if not Assigned(FInstance) then
    FInstance := T.Create;
  Result := FInstance;
end;

end.
