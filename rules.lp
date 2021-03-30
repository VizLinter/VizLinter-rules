%%%%%%%% IS1 Incompatibility issues within each encoding channel.

% Verify the consistency of data field and type 'quantitative'.
hard(enc_type_valid_1,C,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)), channel(E, C).

% Verify the consistency of data field and type 'temporal'.
hard(enc_type_valid_2,C,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime), channel(E, C).

% Only use bin on quantitative or ordinal data.
hard(bin_q_o,C,T) :- type(E,T), bin(E,_), T != quantitative, T != ordinal, channel(E, C).

% Only use log scale with quantitative data.
hard(zero_q,C) :- zero(E), not type(E,quantitative), channel(E, C).

% Only use log scale with non-discrete data.
hard(log_discrete,C) :- log(E), discrete(E), channel(E, C).

% A log scale cannot have a zero baseline in the scale domain.
hard(log_zero,C) :- log(E), zero(E), channel(E, C).

% Use log scale on data that are all positive.
hard(log_non_positive,C) :- log(E), field(E,F), extent(F,MIN,_), MIN <= 0, channel(E, C).

% Use both bin and aggregate on the data in the same time is illegal.
hard(bin_and_aggregate,C) :- bin(E,_), aggregate(E,_), channel(E, C).

% Oridnal data only supports min, max, and median aggregation.
hard(aggregate_o_valid,C,A) :- type(E,ordinal), aggregate(E,A), A != min, A != max, A != median, channel(E, C).

% Temporal only supports min and max aggregation.
hard(aggregate_t_valid,C,A) :- type(E,temporal), aggregate(E,A), A != min, A != max, channel(E, C).

% Nominal data cannot be aggregated.
hard(aggregate_nominal,C) :- aggregate(E,_), type(E,nominal), channel(E, C).

% Use count aggregation or declare a data field of an encoding, instead of doing both of them.
hard(count_q_without_field_1,C) :- aggregate(E,count), field(E,_), channel(E, C).

% The encoding with count aggregation has to be 'quantitative' type.
hard(count_q_without_field_2,C) :- aggregate(E,count), not type(E,quantitative), channel(E, C), not field(E,_).

% Channel size implies order in the data, it is not suitable for nominal data.
hard(size_nominal,C) :- channel(E,size), type(E,nominal), channel(E, C).

% Channel size is not suitable for data with negative values.
hard(size_negative,C) :- channel(E,size), enc_extent(E,MIN,MAX), MIN < 0, MAX > 0, channel(E, C).

% Declare the data field or use count aggregation in each encoding.
hard(encoding_no_field_and_not_count,C) :- not field(E,_), not aggregate(E,count), encoding(E), channel(E, C).

% Use at most 20 categorical colors in the visualization.
hard(color_with_cardinality_gt_twenty,color) :- channel(E,color), discrete(E), enc_cardinality(E,N), N > 20.

% Use stack on x or y channels.
hard(stack_without_x_y,C) :- stack(E,_), not channel(E,x), not channel(E,y), channel(E, C).

% Use stack on continuous data.
hard(stack_discrete,C) :- stack(E,_), discrete(E), channel(E, C).


%%%%%%%% IS2 Incompatibility issues across multiple encoding channels.

% Use each channel only once.
hard(repeat_channel,C):- single_channel(C), 2 { channel(_,C) }.

% Use at least one encoding. Otherwise, the visualization doesn't show anything.
hard(no_encodings) :- not encoding(_).

% Use different fields for x axis and y axis.
hard(same_field_x_and_y) :- field(E1,F1), channel(E1,x); field(E2,F2), channel(E2,y), field(F1), field(F2), F1==F2, x!=y.

% Use count aggregation once in the visualization.
hard(count_twice, C) :- aggregate(E1, count), aggregate(E2, count), channel(E1, C), E1 != E2.

% Only use summative aggretation (count, sum, distinct, valid, missing) with stack in the encoding.
hard(stack_without_summative_agg,C,A) :- stack(E,_), aggregate(E,A), not summative_aggregate_op(A), channel(E, C).

% Only use stack with a color channel encoding discrete data in the visualization.
hard(stack_without_discrete_color_1,color) :- stack(_), not channel_discrete(color), channel(_,color).

% Only use stack with a color channel encoding discrete data in the visualization.
hard(stack_without_discrete_color_2,C,color) :- stack(_), not channel(_,color), channel(_, C), C!=x, C!=y.

% Only use stack with a color channel encoding discrete data in the visualization.
hard(stack_without_discrete_color_3, color) :- stack(_), 1 { channel(_,C) } 2, channel(_, (x;y)).

% When using stack in the visualization, apply aggregation in non-positional continuous channels (color, size) .
hard(stack_with_non_positional_non_agg,C) :- stack(_), non_positional(C), channel(E,C), not aggregate(E,_), continuous(E).

%%%%%%%% IS3 Incompatibility issues between encoding channels and marks.

% Use x or y channel for mark 'point', 'tick', and 'bar'.
hard(point_tick_bar_without_x_or_y) :- mark(point;tick;bar), not channel(_,x), not channel(_,y).

% Use x and y channels for mark 'line' and 'area'.
hard(line_area_without_x_y) :- mark(line;area), not channel(_,(x;y)).

% Use no more than one continuous data in the x and y channels for mark 'bar' and 'tick'.
hard(bar_tick_continuous_x_y) :- mark(bar;tick), channel_continuous(x), channel_continuous(y).

% Mark 'bar', 'tick', 'line', 'area' require some continuous variable on x or y.
hard(bar_tick_area_line_without_continuous_x_y) :- mark(bar;tick;area;line), not channel_continuous(x), not channel_continuous(y).

% Mark 'bar' and 'area' require the scale of x axis to start at zero, when the x axis encodes quantitative data.
hard(bar_area_without_zero_1, x) :- mark(bar;area), channel(E,x), orientation(horizontal), not zero(E), channel_continuous(x).

% Mark 'bar' and 'area' require the scale of y axis to start at zero, when the y axis encodes quantitative data.
hard(bar_area_without_zero_2, y) :- mark(bar;area), channel(E,y), orientation(vertical), not zero(E), channel_continuous(y).

% Use size channel with mark 'point' would be better.
hard(size_without_point, size) :- channel(_,size), not mark(point).

% Only use stacking for mark 'bar' and 'area'.
hard(stack_without_bar_area, C) :- stack(E, _), not mark(bar), not mark(area), channel(E, C).

%%%%%%%% IS4 Typo issues.
% Use valid mark type, including 'area', 'bar', 'line', 'point', 'tick'.
hard(invalid_mark,M) :- mark(M), not marktype(M).

% Use valid channels, including x, y, color, size.
hard(invalid_channel,C) :- channel(_,C), not channel(C).

% Use valid types, including quantitative, nominal, ordinal, temporal.
hard(invalid_type,C,T) :- type(E,T), not type(T), channel(E, C).

% Use valid aggregation, including count, mean, median, min, max, stdev, sum, etc.
hard(invalid_agg,C,A) :- aggregate(E,A), not aggregate_op(A), channel(E, C).

% Use non-negative number for bin amounts (maxbins).
hard(invalid_bin,C,B) :- bin(E,B), not B >= 0, channel(E, C).

