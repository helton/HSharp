unit HSharp.Collections.Interfaces;

interface

uses
  System.Generics.Defaults,
  System.Generics.Collections,
  System.Rtti,
  HSharp.Collections.Interfaces.Internal;

type
  IList<T> = interface(IListInternal<T>)
    ['{42C33DDA-837F-467B-BA5C-6402BB300903}']
    function Add(const Value: T): Integer;
    procedure AddRange(const Values: array of T); overload;
    procedure AddRange(const Collection: IEnumerable<T>); overload;
    procedure AddRange(const Collection: TEnumerable<T>); overload;
    procedure Insert(Index: Integer; const Value: T);
    procedure InsertRange(Index: Integer; const Values: array of T); overload;
    procedure InsertRange(Index: Integer; const Collection: IEnumerable<T>); overload;
    procedure InsertRange(Index: Integer; const Collection: TEnumerable<T>); overload;
    procedure Pack; overload;
    function Remove(const Value: T): Integer;
    procedure Delete(Index: Integer);
    procedure DeleteRange(AIndex, ACount: Integer);
    function Extract(const Value: T): T;
    procedure Exchange(Index1, Index2: Integer);
    procedure Move(CurIndex, NewIndex: Integer);
    function First: T;
    function Last: T;
    procedure Clear;
    function Expand: TList<T>;
    function Contains(const Value: T): Boolean;
    function IndexOf(const Value: T): Integer;
    function LastIndexOf(const Value: T): Integer;
    procedure Reverse;
    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;
    function BinarySearch(const Item: T; out Index: Integer): Boolean; overload;
    function BinarySearch(const Item: T; out Index: Integer; const AComparer: IComparer<T>): Boolean; overload;
    procedure TrimExcess;
    function ToArray: TArray<T>;
  end;

  IDictionary<TKey,TValue> = interface(IDictionaryInternal<TKey,TValue>)
    ['{C52D99FF-F91A-4397-83EB-27DA8FB47705}']
    procedure Add(const Key: TKey; const Value: TValue);
    procedure Remove(const Key: TKey);
    function ExtractPair(const Key: TKey): TPair<TKey,TValue>;
    procedure Clear;
    procedure TrimExcess;
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
    procedure AddOrSetValue(const Key: TKey; const Value: TValue);
    function ContainsKey(const Key: TKey): Boolean;
    function ContainsValue(const Value: TValue): Boolean;
    function ToArray: TArray<TPair<TKey,TValue>>;
  end;

  IStack<T> = interface(IStackInternal<T>)
    ['{99C20C75-B994-41F8-BCF8-C66E4BA07DD6}']
    procedure Clear;
    procedure Push(const Value: T);
    function Pop: T;
    function Peek: T;
    function Extract: T;
    procedure TrimExcess;
    function ToArray: TArray<T>;
  end;

implementation

end.
