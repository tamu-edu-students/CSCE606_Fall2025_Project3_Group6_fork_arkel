# Cucumber 测试失败分布分析

## 总体情况
- **总场景数**: 32 个场景
- **通过**: 12 个场景
- **失败**: 20 个场景
- **通过率**: 37.5%

## User Story 分布

### 2. Movie Search & Metadata (20 个场景)
- **通过**: 5 个场景
- **失败**: 15 个场景
- **通过率**: 25%

#### 详细分布：
1. **movie_search.feature** (4 个场景)
   - 通过: 2 个
   - 失败: 2 个
   - 功能: Search Movies (3 pts)

2. **movie_details.feature** (4 个场景)
   - 通过: 0 个
   - 失败: 4 个
   - 功能: View Movie Details (2 pts)

3. **similar_movies.feature** (3 个场景)
   - 通过: 2 个
   - 失败: 1 个
   - 功能: See Similar Movies (3 pts)

4. **filter_sort.feature** (9 个场景)
   - 通过: 1 个
   - 失败: 8 个
   - 功能: Filter Search Results (3 pts) + Sort Search Results (2 pts)

### 5. Stats Dashboard (12 个场景)
- **通过**: 7 个场景
- **失败**: 5 个场景
- **通过率**: 58.3%

#### 详细分布：
1. **stats_dashboard.feature** (12 个场景)
   - 通过: 7 个
   - 失败: 5 个
   - 功能:
     - Stats Overview (5 pts)
     - Top Contributors (3 pts)
     - Trend Charts (5 pts)
     - Heatmap Activity (2 pts)

## 结论
✅ **所有失败的测试都在您提到的两个 User Story 中：**
- **2. Movie Search & Metadata**: 15 个失败
- **5. Stats Dashboard**: 5 个失败
- **总计**: 20 个失败

没有其他 User Story 的测试失败。

