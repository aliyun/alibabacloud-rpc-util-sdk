using System.Collections.Generic;

using Tea;

namespace tests.Models
{
    public class TestConvertModel : TeaModel
    {
        public string RequestId { get; set; }

        public int NoMap { get; set; }

        public Dictionary<string, object> Dict { get; set; }

        public TestConvertSubModel SubModel { get; set; }

        public class TestConvertSubModel : TeaModel
        {
            public string RequestId { get; set; }

            public int Id { get; set; }
        }
    }
}
