NR == 1 { for(column=1; column <= NF; column++) values[column]=$column; }
NR > 1 { output=""
        for(column=1; column <= NF; column++)
                if($column) output=output ? output "," values[column] : values[column]
        print output }
