# Experimental Environment

We conducted experiments to investigate how the size of the Key and Value affects Compaction.

| Various **Key** Size | Various **Value** Size |
|----------------------|------------------------|
| 16 byte              | 256 byte               |
| 32 byte              | 1 kb                   |
| 64 byte              | 4 kb                   |
| 128 byte             | 16 kb                  |

For benchmarks, we utilized only `fillrandom` and `readrandom` where Compaction occurs.

| Experiment Setup     | Benchmarks |
|----------------------|------------|
| version 1.23         | fillrandom |
| CPU Intel Xeon(R)    | readrandom |
|                      | ~~fillseq~~|
|                      | ~~readseq~~|

## 1. 'fillrandom' with Variable Key Size

In `fillrandom` with variable key size, we expected the WAF latency to gradually increase. However, contrary to our expectations, the WAF decreased as the key size decreased.

![image](https://user-images.githubusercontent.com/86946575/181190994-d47ec06f-3ca6-4589-9c33-b9b075662053.png)

## 2. 'fillrandom' with Variable Value Size

For variable value size, we anticipated that increasing the size by 4 times would result in a 4-fold performance difference. However, the results showed:

- **Compaction latency** increased by 5.18 times.
- **Latency** increased by 5.33 times.

This seems to be because as the value size increased, Compaction occurred more frequently.

![image](https://user-images.githubusercontent.com/86946575/181191389-3b6f2350-37fc-4d1c-9d3f-0c3f1925a744.png)

## 3. 'readrandom' with Variable Key/Value Size

In `readrandom` with variable value size, latency increased by more than 100 times at 4kb and 16kb.

![image](https://user-images.githubusercontent.com/86946575/181191670-7da09cdf-5b99-41e8-a8fa-6650fb9567e1.png)

## Re-experiment Due to Unexpected Results

In the `fillrandom` benchmark experiment, we found the rate of change in the graph inappropriate, prompting a re-experiment. We calculated the average of values obtained by repeating the same experiment three times and compared it with the previous experiment.

## Re-experiment-1 'fillrandom' with Variable Key Size

Measured by the average of values repeated three times.

![image](https://user-images.githubusercontent.com/106041072/188067454-ab99fc82-ee58-45c2-93d8-5e03cd8285a6.png)

As a result, the **WAF** continued to decrease as in the previous experiment. Further research was conducted to understand why the **WAF** continued to decrease contrary to expectations.

![image](https://user-images.githubusercontent.com/106041072/188067476-fd1f0d75-e041-45d7-ab62-395132b6d600.png)

## Re-experiment-2 'fillrandom' with Variable Value Size

Measured by the average of values repeated three times. To ensure more accurate measurements, we subdivided the intervals further.

![image](https://user-images.githubusercontent.com/106041072/188064488-c6a8640d-c2f2-4d24-bca7-14b12cdbfba9.png)

As a result, we obtained more precise results with **latency** decreasing from 5.33 times to 2.5 times.

![image](https://user-images.githubusercontent.com/106041072/188066351-8090ecc3-813f-4afb-b960-ed4ae737f1c8.png)

Similarly, we calculated the average of values repeated three times and subdivided the intervals further for comparison.

![image](https://user-images.githubusercontent.com/106041072/188066684-fe2aa797-0280-4714-ab78-f52e89675a8a.png)

As a result, we obtained more precise results with **compaction latency** decreasing from 5.18 times to 3.5 times.

![image](https://user-images.githubusercontent.com/106041072/188066725-a0430329-c16c-4e85-a69b-8837ba8613b4.png)

## Conclusion and Discussion

We conducted experiments based on the hypothesis that key/value size affects compaction. In the case of `fillrandom`, as the value size increased, the number of values to be compacted increased, resulting in decreased throughput and increased WAF, latency, and compaction latency. In the case of `readrandom`, as the value to be read at once increased, latency also increased.

The results from `fillrandom` with increasing key size were peculiar. As the key size increased, the number of keys within that size remained the same, but the key range increased (see image below). Therefore, when compaction is triggered, the size to be loaded into memory, merge sorted, and written back to disk increased, leading to increased latency and compaction latency. However, since the number of keys within the range remained the same, the overlapping range was the same, allowing for more write processing over a larger range at once, resulting in decreased WAF and increased throughput.

![image](https://user-images.githubusercontent.com/106041072/188073166-66f5514e-cc06-4131-bc36-67a923b129da.png)
