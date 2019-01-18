Generic class for paging results

```
namespace Infrastructure.CrossCutting
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    /// <summary>
    /// Paginates an IEnumerable of T
    /// </summary>
    /// <typeparam name="T">Class or primitive type</typeparam>

    public sealed class PagedList<T> : List<T>
    {
        public PagedList()
        {
            this.Number = 1;
            this.TotalPages = 1;
        }

        public PagedList(IEnumerable<T> content, int pageNumber, int pageSize, int count)
        {
            this.TotalCount = count;
            this.PageSize = pageSize;
            this.Number = pageNumber;
            this.TotalPages = (int)Math.Ceiling(count / (double)pageSize);
            this.AddRange(content);
        }

        /// <summary>
        /// Current page number
        /// </summary>
        public int Number { get; set; }

        /// <summary>
        /// Total of pages
        /// </summary>
        public int TotalPages { get; set; }

        /// <summary>
        /// Items per page
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// total count of items
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// All source entries to be paged
        /// </summary>
        public IEnumerable<T> Entries { get; set; }


        /// <summary>
        /// Creates a page with source collection
        /// </summary>
        /// <param name="source"></param>
        /// <param name="pageNumber"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        public static PagedList<T> Create(IEnumerable<T> source, int pageNumber, int pageSize)
        {
            // TODO: convert this to async task and use asyncEnumerable once available in C#
            var count = source.Count();
            var items = source.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToList();
            return new PagedList<T>(items, count, pageNumber, pageSize);
        }
    }
}
```

## Paging sample
```
// figure how many pages do we need
List<int> lotsOfMerchantIds = ...;
const double pageSize = 50.0;
int totalOfRecords = stores.Count();
int totalPages = (int)Math.Ceiling(totalOfRecords / pageSize);

// then you could perform multiple service calls for each chunk / page 
ParallelLoopResult storesLoop = Parallel.For(0, totalPages, page =>
{
    PagedList<int> pagedStoreIds = PagedList<int>.Create(lotsOfMerchantIds, pageNumber: page + 1, pageSize);

    // pass a subset of data as argument and avoid querystring maximum size exceeded
    IEnumerable<Store> stores = this.service.GetStores(pagedStoreIds);

    // do stuff
    
});
```
