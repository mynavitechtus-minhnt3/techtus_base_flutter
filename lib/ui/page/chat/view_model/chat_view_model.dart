import 'dart:async';
import 'dart:math';

import 'package:chatview/chatview.dart' hide MessageType, MessageStatus;
import 'package:clock/clock.dart';
import 'package:dartx/dartx.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../index.dart';

final chatViewModelProvider = StateNotifierProvider.autoDispose
    .family<ChatViewModel, CommonState<ChatState>, FirebaseConversationData>(
  (ref, conversation) => ChatViewModel(
    ref,
    conversation,
  ),
);

class ChatViewModel extends BaseViewModel<ChatState> {
// ignore: prefer_named_parameters
  ChatViewModel(
    this._ref,
    FirebaseConversationData conversation,
    // ignore: missing_run_catching
  )   : _messageDataMapper = _ref.messageDataMapper(conversation.id),
        super(
          CommonState(
            data: ChatState(conversation: conversation),
          ),
        );

  final Ref _ref;
  final MessageDataMapper _messageDataMapper;

  StreamSubscription<List<LocalMessageData>>? _messagesSubscription;
  StreamSubscription<void>? _messagesFromFirestoreSubscription;
  StreamSubscription<FirebaseConversationData?>? _conversationSubscription;

  LocalMessageData? get oldestMessage => data.messages.lastOrNull;

  LocalMessageData? get latestMessage => data.messages.firstOrNull;

  void init() {
    initState();
    listenToConversationDetail();
    listenToMessagesFromFirestore(Constant.itemsPerPage);
    listenToLocalmessages();
  }

  void initState() {
    data = data.copyWith(
      isAdmin: _isConversationAdmin(data.conversation),
    );
  }

  Future<void> onLoadMore() async {
    if (oldestMessage == null) {
      return;
    }

    // ignore: missing_run_catching
    final messages = await _ref.firebaseFirestoreService.getOlderMessages(
      latestMessageId: oldestMessage!.uniqueId,
      conversationId: data.conversation.id,
    );

    Log.d('load more firestore messages: $messages'.hardcoded);

    final isLastPage = messages.length < Constant.itemsPerPage;

    // ignore: missing_run_catching
    await _ref.appDatabase.putMessages(_messageDataMapper.mapToLocalList(messages));

    data = data.copyWith(isLastPage: isLastPage);
  }

  void listenToLocalmessages() {
    // ignore: missing_run_catching
    _messagesSubscription?.cancel();
    // ignore: missing_run_catching
    _messagesSubscription = _ref.appDatabase.getMessagesStream(data.conversation.id).listen(
      (event) {
        Log.d('new local message event: $event'.hardcoded);
        data = data.copyWith(messages: event);
      },
      onError: (e) {
        Log.d('getNewLocalMessageStream error by $e'.hardcoded);
      },
    );
  }

  void listenToMessagesFromFirestore(int limit) {
    _messagesFromFirestoreSubscription?.cancel();
    _messagesFromFirestoreSubscription = Rx.combineLatest(
      [
        // ignore: missing_run_catching
        _ref.firebaseFirestoreService.getMessagesStream(
          conversationId: data.conversation.id,
          limit: limit,
        ),
        _ref.connectivityHelper.onConnectivityChanged,
      ],
      (values) {
        final newMessages = values.first.safeCast<List<FirebaseMessageData>>() ?? [];
        final isConnected = values[1].safeCast<bool>();

        if (isConnected == true && newMessages.isNotEmpty) {
          // ignore: missing_run_catching
          _ref.appDatabase.putMessages(_messageDataMapper.mapToLocalList(newMessages));
        }
      },
    ).listen(
      (event) {},
      onError: (e) {
        Log.d('listenTomessagesFromFirestore error by $e'.hardcoded);
      },
    );
  }

  void listenToConversationDetail() {
    // ignore: missing_run_catching
    _conversationSubscription?.cancel();
    _conversationSubscription =
        // ignore: missing_run_catching
        _ref.firebaseFirestoreService.getConversationDetailStream(data.conversation.id).listen(
      (event) {
        Log.d('getConversationDetailStream event: $event'.hardcoded);
        if (event != null) {
          data = data.copyWith(
            conversation: event,
            isAdmin: _isConversationAdmin(event),
          );
        }
      },
      onError: (e) {
        Log.d('listenToConversationDetail error by $e'.hardcoded);
      },
    );
  }

  @override
  void dispose() {
    _messagesFromFirestoreSubscription?.cancel();
    _messagesFromFirestoreSubscription = null;
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _conversationSubscription?.cancel();
    _conversationSubscription = null;
    super.dispose();
  }

  Future<void> sendMessage({
    required String message,
    ReplyMessage? replyMessage,
  }) async {
    await runCatching(
      handleLoading: false,
      action: () async {
        final latestMessageCreatedAt = latestMessage?.createdAt ?? 0;
        final currentUserId = _ref.appPreferences.userId;
        final conversationId = data.conversation.id;

        // nếu users điều chỉnh giờ quá khứ -> điều chỉnh thành tương lai để tin nhắn là latest
        final now = max(clock.now().millisecondsSinceEpoch, latestMessageCreatedAt + 1);
        final messageId = _ref.firebaseFirestoreService.createMessageId(conversationId);

        final localMessage = LocalMessageData(
          conversationId: conversationId,
          senderId: currentUserId,
          message: message,
          type: MessageType.text,
          status: MessageStatus.sending,
          uniqueId: messageId,
          userId: currentUserId,
          createdAt: now,
          updatedAt: now,
          replyMessage: replyMessage != null
              ? LocalReplyMessageData(
                  userId: currentUserId,
                  replyToMessageId: replyMessage.messageId,
                  type: MessageType.fromChatViewMessageType(replyMessage.messageType),
                  replyToMessage: replyMessage.message,
                  replyByUserId: currentUserId,
                  replyToUserId: replyMessage.replyTo,
                  conversationId: conversationId,
                )
              : null,
        );

        await _ref.appDatabase.putMessage(localMessage);

        await _ref.firebaseFirestoreService.createMessage(
          conversationId: data.conversation.id,
          message: _messageDataMapper.mapToRemote(localMessage),
        );
      },
    );
  }

  Future<void> deleteConversation() async {
    await runCatching(
      action: () async {
        await _ref.sharedViewModel.deleteConversation(data.conversation);
        await _ref.nav.pop();
      },
    );
  }

  bool _isConversationAdmin(FirebaseConversationData conversation) {
    return conversation.members
            .firstOrNullWhere((element) => element.userId == _ref.appPreferences.userId)
            ?.isConversationAdmin ==
        true;
  }
}
