using Tea;

namespace tests.Models
{
    public class ToBodyModel : TeaModel
    {
        [NameInMap("ListAllMyBucketsResult")]
        public ListAllMyBucketsResult listAllMyBucketsResult { get; set; }

    }
}
