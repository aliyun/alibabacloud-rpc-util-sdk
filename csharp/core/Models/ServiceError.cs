using Tea;

namespace AlibabaCloud.Commons.Models
{
    public class ServiceError
    {
        [NameInMap("Code")]
        public string Code { get; set; }

        [NameInMap("Message")]
        public string Message { get; set; }

        [NameInMap("RequestId")]
        public string RequestId { get; set; }

        [NameInMap("HostId")]
        public string HostId { get; set; }
    }
}
