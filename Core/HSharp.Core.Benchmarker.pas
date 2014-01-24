{
  # Author: Berry Kelly
  # Link: http://blog.barrkel.com/2008/08/anonymous-methods-in-testing-profiling.html
}

unit HSharp.Core.Benchmarker;

interface

uses
  System.SysUtils;

type
  TBenchmarker = class
  private
    const
      DefaultIterations = 3;
      DefaultWarmups = 1;
    var
      FReportSink: TProc<string,Double>;
      FWarmups: Integer;
      FIterations: Integer;
      FOverhead: Double;
    class var
      FFreq: Int64;
    class procedure InitFreq;
  public
    constructor Create(const AReportSink: TProc<string,Double>);
    class function Benchmark(const Code: TProc;
      Iterations: Integer = DefaultIterations;
      Warmups: Integer = DefaultWarmups): Double; overload;
    procedure Benchmark(const Name: string; const Code: TProc); overload;
    function Benchmark<T>(const Name: string; const Code: TFunc<T>): T; overload;
    property Warmups: Integer read FWarmups write FWarmups;
    property Iterations: Integer read FIterations write FIterations;
  end;

implementation

uses
  Winapi.Windows;

{ TBenchmarker }

constructor TBenchmarker.Create(const AReportSink: TProc<string, Double>);
begin
  InitFreq;
  FReportSink := AReportSink;
  FWarmups := DefaultWarmups;
  FIterations := DefaultIterations;

  // Estimate overhead of harness
  FOverhead := Benchmark(procedure begin end, 100, 3);
end;

class procedure TBenchmarker.InitFreq;
begin
  if (FFreq = 0) and not QueryPerformanceFrequency(FFreq) then
    raise Exception.Create('No high-performance counter available.');
end;

procedure TBenchmarker.Benchmark(const Name: string; const Code: TProc);
begin
  FReportSink(Name, Benchmark(Code, Iterations, Warmups) - FOverhead);
end;

class function TBenchmarker.Benchmark(const Code: TProc; Iterations,
  Warmups: Integer): Double;
var
  start, stop: Int64;
  i: Integer;
begin
  InitFreq;

  for i := 1 to Warmups do
    Code;

  QueryPerformanceCounter(start);
  for i := 1 to Iterations do
    Code;
  QueryPerformanceCounter(stop);

  Result := (stop - start) / FFreq / Iterations;
end;

function TBenchmarker.Benchmark<T>(const Name: string; const Code: TFunc<T>): T;
var
  start, stop: Int64;
  i: Integer;
begin
  for i := 1 to FWarmups do
    Result := Code;

  QueryPerformanceCounter(start);
  for i := 1 to FIterations do
    Result := Code;
  QueryPerformanceCounter(stop);

  FReportSink(Name, (stop - start) / FFreq / Iterations - FOverhead);
end;

end.
