# Examples

`templateer test-data.json simple.erb`

```
{"test_array"=>["1234", "5678", "90"], "test_hash"=>{"k1"=>"v1", "k2"=>"v2"}}

1234
5678
90

K: k1, V: v1
K: k2, V: v2

Truthy helper positive (y, yes, true, Fixnum != 0): [true, true, true, true]
Truthy helper negative (n, no, false, 0): [false, false, false, false]⏎
```