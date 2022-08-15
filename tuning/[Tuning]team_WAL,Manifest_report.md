# Tuning report

## Hyphothesis

### Options
----------------

#### write_buffer_size
    write_buffer_size 값이 클수록 대량 로드 시에 성능이 향상된다.
    max_memory_size(= write_buffer_size + block_cache_size) <= 1GB 이므로
    1GB 일 때 Load의 성능이 최대가 될 것이다.
    WorkloadA : Read(50) + Modify(50) 
    WorkloadB : Read(95) + Modify(5)
    WorkloadD : Read(95) + Modify(5)
    따라서 모든 workload에서 Modify를 하므로 write_buffer_size가 커질수록 
    LoadA, RunA, RunB, RunD 모두에서 성능 향상이 있을 것으로 예상된다. 
#### max_file_size
     파일의 최대 크기가 커지면 compaction 시간이 길어져 latency가 느려질 수 있다.
     따라서 파일 시스템에 적합한 값을 찾는 것이 중요하다고 예상된다.
     만약 파일 시스템이 비교적 큰 파일을 사용하는 것이 효율적이라면 파일 크기를 증가
     시킬 수도 있다.
#### block_size
     block마다 패킹된 데이터의 대략적인 크기를 설정하는 옵션이다.
     여기에서의 block의 크기는 압축되지 않은 데이터이므로 압축이 빠르게 되려면 크기가 
     작아야 성능에 유리할 것이라고 예상했다.
#### block_restart_interval
     정확히 어떤 기능을 하는 옵션인지 이해하지 못했지만
     // Most clients should leave this parameter alone.
     leveldb에서는 대부분의 클라이언트에서 변경하지 않는 것을 권장했으므로
     이에 따라 실험을 진행했다.
#### block_cache_size
     일반적으로 cache의 크기가 클 수록 히트율이 높아지기 때문에 좋다고 생각한다.
     하지만 실제로는 cache의 비용이나 여러 측면에서 무작정 크게 할 수 없으므로 옵션에
     적용한 크기만큼 성능이 나오지는 않을 것이다. 
#### compression
    compression의 옵션은 kNoCompression과 kSnappyCompression 2개의 옵션이 설정 가능하다. 
    // Note that these speeds are significantly faster than most
    // persistent storage speeds, and therefore it is typically never
    // worth switching to kNoCompression.  Even if the input data is
    // incompressible, the kSnappyCompression implementation will
    // efficiently detect that and will switch to uncompressed mode.
    leveldb의 compression 옵션에 대한 설명인데 위의 설명에 따르면 kNoCompression 옵션으로 변경할 필요가
    없다고 되어 있어 kSnappyCompression 옵션 일 때 성능이 더 좋을것으로 예상된다.
#### filter_policy
    default로 NewBloomFilterPolicy로 설정이 되어 있고 지난 bloomfilter 팀의 benchmark 발표에서 
    10bit 일 때 가장 효율적이라고 발표를 했으므로 따로 설정하지 않고 10bit로 실험을 진행했다.



## Experiments

### Options
----------------

#### write_buffer_size
    64, 128, 256, 512MB를 3개의 다른 서버에서 실험을 진행했다.
    실험을 진행해 보니 64MB를 넘어가면 큰 변화가 없었다.
#### max_file_size
    3개의 다른 서버 환경에서 max_file_size의 default 값이 2MB에서 2배씩 증가시키면서 실험을 진행했고 64MB ~ 1GB까지 실험을 해보았다.
#### block_size
    default 값인 4kB에서 2배씩 증가 또는 감소시켜서 여러 개의 값을 설정해서 실험을 진행했다. 
#### block_restart_interval
    default 값인 16으로 실험을 진행했다.
#### block_cache_size
    최대한 크기를 증가시켜보고 성능이 향상되지 않는 시점의 값을 찾는 것을 목표로 실험을 진행했다.
#### compression
    kNoCompression과 kSnappyCompression에서 모두 실험을 진행해보았는데 큰 차이가 없었지만 kNoCompression에서 성능이 향상되지는 않았다.
#### filter_policy
    10bit로 두고 다른 옵션들을 변경해가며 실험을 진행했다.

## Results

### Options
----------------

#### write_buffer_size
    특정한 값을 넘어가면 미리 정해진 값으로 고정이 되는 것 같다.
    서버가 다른 것도 영향을 줄 수 있는지는 확인을 해봐야겠지만 3개의 서버에서 같은 결과가 나오지는 않아서 평균값을 결과값으로 정했다.
    
#### max_file_size
    64MB 이상부터는 큰 차이가 없었고 일반적인 경우에 파일의 크기가 클수록 성능에 안 좋을 수 있다고 생각해서 비슷한 결과 값 중에서 
    가장 작은 64MB을 결과값으로 정했다.
#### block_size
    우리의 실험에서는 8kB 일 때 값들이 일관적으로 잘 나오는 것을 확인했고 공통된 결과가 나왔으므로 8kB를 결과값으로 정했다.
#### block_restart_interval
    16
#### block_cache_size
    캐시의 크기가 128MB부터는 성능이 향상 되지 않았고 반복적으로 실험을 돌려봐도 높은 성능이 나오는 것을 확인해서 
    128MB를 결과값으로 정했다.
#### compression
    kSnappyCompression
#### filter_policy
    10bit
