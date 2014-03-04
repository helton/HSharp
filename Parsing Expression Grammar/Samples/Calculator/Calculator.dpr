program Calculator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  HSharp.Core.Benchmarker,
  Calc in 'Calc.pas';

var
  Calc: ICalc;

  procedure DoBenchmarkAndWrite(const aProc: TProc);
  begin
    Writeln(Format('Elapsed time = %15.9f ms',
      [TBenchmarker.Benchmark(
      aProc
      )]
    ));
    Writeln(StringOfChar('-', 50));
  end;

  procedure EvalAndWrite(const aExpression: string);
  begin
    DoBenchmarkAndWrite(
      procedure
      begin
        Writeln(('"' + aExpression + '"'):20, ' = <', Calc.Evaluate(
          aExpression):10:2, '>');
      end
    );
  end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    Writeln(StringOfChar('-', 50));
    DoBenchmarkAndWrite(
      procedure
      begin
        Writeln('Calc := TCalc.Create');
        Calc := TCalc.Create;
      end
    );
    EvalAndWrite('111111');
    EvalAndWrite(' 222222');
    EvalAndWrite('333333  ');
    EvalAndWrite('11+22');
    EvalAndWrite('11-22');
    EvalAndWrite('1-2+3-4+5-6+7');
    EvalAndWrite('11 + 22');
    EvalAndWrite(' 11 + 22');
    EvalAndWrite('11 + 22 ');
    EvalAndWrite(' 11 + 22 ');
    EvalAndWrite('   11   +    22   ');
    EvalAndWrite('11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99+'+
                 '11+22+33+44+55+66+77+88+99');
    Readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
