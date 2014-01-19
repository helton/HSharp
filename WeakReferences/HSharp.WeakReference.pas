unit HSharp.WeakReference;

interface

type
  Weak<T> = record
  private
    FInstance: Pointer;
    function AsType: T;
  public
    class operator Implicit(aWeak: Weak<T>): T;
    class operator Implicit(aValue: T): Weak<T>;
  end;

implementation

{ Weak<T> }

function Weak<T>.AsType: T;
begin
  Result := T(FInstance^);
end;

class operator Weak<T>.Implicit(aWeak: Weak<T>): T;
begin
  Result := aWeak.AsType;
end;

class operator Weak<T>.Implicit(aValue: T): Weak<T>;
begin
  Result.FInstance := @aValue;
end;

end.
